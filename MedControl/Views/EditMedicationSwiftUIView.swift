//
//  EditMedicationSwiftUIView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 17/01/21.
//

import SwiftUI
import CoreData
import NotificationCenter


struct EditMedicationSwiftUIView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let medication: Medication
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var date = Date()
    @State private var repeatPeriod = ""
    @State private var notes = ""
    @State private var pickerView = true
    
    
    var body: some View {
        NavigationView{
            Form {
                TextField("Nome do medicamento", text: $name)
                    .onAppear {
                        if pickerView {
                            self.name = self.medication.name != nil ? "\(self.medication.name!)" : ""
                        }
                    }
                    .disableAutocorrection(true)
                
                TextField("Quantidade na caixa", text: $quantity).keyboardType(.numberPad)
                    .onAppear {
                        if pickerView {
                            self.quantity = (self.medication.quantity != 0) ? "\(self.medication.quantity)" : ""
                        }
                    }
                
                DatePicker("Data", selection: $date, in: Date()...)
                
                Picker(selection: $repeatPeriod, label: Text("Repetir")) {
                    ForEach(RepeatPeriod.periods, id: \.self) { periods in
                        Text(periods).tag(periods)
                    }
                }.onAppear {
                    pickerView = false
                }
                
                Section{
                    Text("Notas")
                    TextEditor(text: $notes).padding()
                        .onAppear {
                            if pickerView {
                                self.notes = self.medication.notes != nil ? "\(self.medication.notes!)" : ""
                            }
                        }
                }
                
                
                
            }
            .navigationBarTitle(Text("Editar Medicamento"),displayMode: .inline)
            .navigationBarItems(leading:
                                    Button("Cancelar", action: {
                                        self.presentationMode.wrappedValue.dismiss()
                                    })
                                , trailing:
                                    Button("Salvar", action: {
                                        editMedication(newMedication: medication)
                                        self.presentationMode.wrappedValue.dismiss()
                                    })
            )
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
    
    private func editMedication(newMedication: Medication) {
        withAnimation {
            
            newMedication.name = name
            if let quantity = Int32(quantity) {
                newMedication.quantity = quantity
            }
            
            newMedication.leftQuantity = newMedication.quantity
            newMedication.date = date
            newMedication.repeatPeriod = repeatPeriod
            newMedication.notes = notes
            newMedication.isSelected = false
            
            
            switch newMedication.repeatPeriod {
            case "Nunca":
                newMedication.repeatSeconds = 0.0
            case "15 minutos":
                newMedication.repeatSeconds = 900.0
            case "30 minutos":
                newMedication.repeatSeconds = 1800.0
            case "1 hora":
                newMedication.repeatSeconds = 3600.0
            case "2 horas":
                newMedication.repeatSeconds = 7200.0
            case "4 horas":
                newMedication.repeatSeconds = 14400.0
            case "8 horas":
                newMedication.repeatSeconds = 28800.0
            case "12 horas":
                newMedication.repeatSeconds = 43200.0
            case "1 dia":
                newMedication.repeatSeconds = 86400.0
            case "1 semana":
                newMedication.repeatSeconds = 604800.0
            case "1 mês":
                newMedication.repeatSeconds = 2419200.0
            default:
                newMedication.repeatSeconds = 0.0
                break
            }
            let notificationStatusnotificationStatus = scheduleNotification(medication: newMedication)
            
            if(notificationStatusnotificationStatus) {
                saveContext()
            } else {
                print("Erro na criação da notificação")
            }
            
        }
    }
    private func scheduleNotification(medication: Medication) -> Bool {
        
        notificationPermission()
        
        let content = UNMutableNotificationContent()
        content.title = "Lembrete"
        content.body = "Tomar \(medication.name ?? "Medicamento")"
        content.sound = UNNotificationSound.default
        
        guard let timeInterval = medication.date?.timeIntervalSinceNow else {return false}
        
        guard timeInterval > 0 else {
            return false
        }
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: medication.id!, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        
        return true
        
    } //Func: scheduleNotification
    
    private func notificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])  {
            success, error in
            if success {
                print("authorization granted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}


struct EditMedicationSwiftUIView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let medication = Medication(context: moc)
        
        return NavigationView {
            EditMedicationSwiftUIView(medication: medication)
        }
        
        
    }
}
