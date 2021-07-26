//
//  MedicationManager.swift
//  MedControl
//
//  Created by Fabio Fiorita on 21/07/21.
//

import Foundation
import CoreData

final class MedicationManager: ObservableObject {
    private var notificationManager = NotificationManager()
    private var userSettings = UserSettings()
    
    func saveContext(viewContext: NSManagedObjectContext) {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Failed to save Medication: \(error)")
        }
    }
    
    
    func addMedication(name: String, remainingQuantity: Int32, boxQuantity: Int32, date: Date, repeatPeriod: String, notes: String, notificationType: String, viewContext: NSManagedObjectContext) {
        
        let newMedication = Medication(context: viewContext)
        newMedication.name = name
        newMedication.remainingQuantity = remainingQuantity
        newMedication.boxQuantity = boxQuantity
        newMedication.id = UUID().uuidString
        newMedication.date = date
        newMedication.repeatPeriod = repeatPeriod
        newMedication.notes = notes
        newMedication.isSelected = false
        newMedication.repeatSeconds = convertToSeconds(newMedication.repeatPeriod ?? "")
        newMedication.notificationType = notificationType
        
        guard let timeInterval = newMedication.date?.timeIntervalSinceNow else {return}
        guard let identifier = newMedication.id else {return}
        if timeInterval > 0 {
            notificationManager.deleteLocalNotifications(identifiers: [identifier])
            notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: "Tomar \(newMedication.name ?? "Medicamento")", timeInterval: timeInterval) { error in
                if error == nil {
                    print("Notificação criada com id: \(identifier)")
                }
            }
        }
        
        saveContext(viewContext: viewContext)
    }
    
    func editMedication(name: String, remainingQuantity: Int32, boxQuantity: Int32, date: Date, repeatPeriod: String, notes: String, notificationType: String, viewContext: NSManagedObjectContext, medication: Medication) {
        
        medication.name = name
        medication.remainingQuantity = remainingQuantity
        medication.boxQuantity = boxQuantity
        medication.id = UUID().uuidString
        medication.date = date
        medication.repeatPeriod = repeatPeriod
        medication.notes = notes
        medication.isSelected = false
        medication.repeatSeconds = convertToSeconds(medication.repeatPeriod ?? "")
        medication.notificationType = notificationType
        
        guard let timeInterval = medication.date?.timeIntervalSinceNow else {return}
        guard let identifier = medication.id else {return}
        if timeInterval > 0 {
            notificationManager.deleteLocalNotifications(identifiers: [identifier])
            notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: "Tomar \(medication.name ?? "Medicamento")", timeInterval: timeInterval) { error in
                if error == nil {
                    print("Notificação criada com id: \(identifier)")
                }
            }
        }
        
        saveContext(viewContext: viewContext)
    }
    
    func deleteMedication(medication: Medication, viewContext: NSManagedObjectContext) {
        guard let identifier = medication.id else {return}
        let identifierRepeat = (medication.id ?? UUID().uuidString) + "-Repiting"
        notificationManager.deleteLocalNotifications(identifiers: [identifier, identifierRepeat])
        viewContext.delete(medication)
    }
    
    func updateRemainingQuantity(medication: Medication, viewContext: NSManagedObjectContext) -> Bool {
        var success = true
        if medication.remainingQuantity > 1 {
            if Double(medication.remainingQuantity) <= Double(medication.boxQuantity) * (userSettings.limitMedication/100.0) {
                if userSettings.limitNotification {
                    print("USERDEFAULTS-----------")
                    print(userSettings.limitNotification)
                    print(userSettings.limitMedication)
                    print("---------------------------")
                    let identifier = (medication.id ?? UUID().uuidString) + "-Repiting"
                    let dateMatching = Calendar.current.dateComponents([.hour,.minute], from: userSettings.limitDate)
                    let hour = dateMatching.hour
                    let minute = dateMatching.minute
                    notificationManager.deleteLocalNotifications(identifiers: [identifier])
                    notificationManager.createLocalNotificationByDateMatching(identifier: identifier, title: "Comprar \(medication.name ?? "Medicamento")", hour: hour ?? 12, minute: minute ?? 00) { error in
                        if error == nil {
                            print("Notificação criada com id: \(identifier)")
                        }
                    }
                }
            }
            medication.remainingQuantity -= 1
            
            let historic = Historic(context: viewContext)
            historic.dates = Date()
            historic.medication = medication
            if !(medication.repeatPeriod == "Nunca") {
                rescheduleNotification(forMedication: medication, forHistoric: historic)
            }
            
            if historic.medicationStatus == "Não tomou" {
                success = false
            }
            saveContext(viewContext: viewContext)
            success = true
        } else {
            deleteMedication(medication: medication, viewContext: viewContext)
            success = false
        }
        return success
    }
    
    func rescheduleNotification(forMedication medication: Medication, forHistoric historic: Historic) {
        medicationStatus(forMedication: medication, forHistoric: historic)
        if medication.notificationType == "Regularmente" {
            medication.date = Date(timeInterval: medication.repeatSeconds, since: medication.date ?? Date())
        } else {
            medication.date = Date(timeIntervalSinceNow: medication.repeatSeconds)
        }
        guard let timeInterval = medication.date?.timeIntervalSinceNow else {return}
        guard let identifier = medication.id else {return}
        if timeInterval > 0 {
            notificationManager.deleteLocalNotifications(identifiers: [identifier])
            notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: "Tomar \(medication.name ?? "Medicamento")", timeInterval: timeInterval) { error in
                if error == nil {}
            }
        } else {
            historic.medicationStatus = "Não tomou"
        }
    }
    
    func medicationStatus(forMedication medication: Medication, forHistoric historic: Historic) {
        var timeIntervalComparation = 0.0
        if let timeIntervalDate = medication.date?.timeIntervalSince(historic.dates ?? Date()) {
            timeIntervalComparation = timeIntervalDate
        }
        if timeIntervalComparation < -900.0 {
            historic.medicationStatus = "Atrasado"
        } else {
            historic.medicationStatus = "Sem Atraso"
        }
    }
    
    func refreshRemainingQuantity(medication: Medication, viewContext: NSManagedObjectContext) {
        medication.remainingQuantity += medication.boxQuantity
        saveContext(viewContext: viewContext)
        guard let id = medication.id else {return}
        let identifier = id + "-Repiting"
        notificationManager.deleteLocalNotifications(identifiers: [identifier])
    }
    
    func convertToSeconds(_ time: String) -> Double {
        var seconds = 3.0
        switch time {
        case "Nunca":
            seconds = 0.0
        case "1 hora":
            seconds = 3600.0
        case "2 horas":
            seconds = 7200.0
        case "4 horas":
            seconds = 14400.0
        case "6 horas":
            seconds = 21600.0
        case "8 horas":
            seconds = 28800.0
        case "12 horas":
            seconds = 43200.0
        case "1 dia":
            seconds = 86400.0
        case "2 dias":
            seconds = 172800.0
        case "5 dias":
            seconds = 432000.0
        case "1 semana":
            seconds = 604800.0
        case "2 semanas":
            seconds = 1209600.0
        case "1 mês":
            seconds = 2419200.0
        case "3 meses":
            seconds = 72576000.0
        case "6 meses":
            seconds = 145152000.0
        default:
            break
        }
        return seconds
    }
}


