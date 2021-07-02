//
//  AddEditMedicationSwiftUIView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 17/01/21.
//

import SwiftUI
import NotificationCenter

struct RepeatPeriod{
    static let periods = [
        "Nunca",
        "15 minutos",
        "30 minutos",
        "1 hora",
        "2 horas",
        "4 horas",
        "8 horas",
        "12 horas",
        "1 dia",
        "1 semana",
        "1 mês"
    ]
}

struct AddMedicationSwiftUIView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var quantity = ""
    @State private var date = Date()
    @State private var repeatPeriod = ""
    @State private var notes = ""
    @State var showAlert = false
    
    @ObservedObject var userSettings = UserSettings()
    
    var body: some View {
        NavigationView{
        Form {
            
            TextField("Nome do Medicamento", text: $name).disableAutocorrection(true)
            TextField("Quantidade na Caixa", text: $quantity).keyboardType(.numberPad)
            
            DatePicker("Data de Início", selection: $date, in: Date()...)
                
            
                Picker(selection: $repeatPeriod, label: Text("Repetir")) {
                    ForEach(RepeatPeriod.periods, id: \.self) { periods in
                        Text(periods).tag(periods)
                    }
                }
            
            
            Section{
                Text("Notas")
                TextEditor(text: $notes).padding()
            }
            
            
            
        }
        .navigationBarTitle(Text("Novo Medicamento"),displayMode: .inline)
        .navigationBarItems(leading:
            Button("Cancelar", action: {
                self.presentationMode.wrappedValue.dismiss()
            })
        , trailing:
            Button("Salvar", action: {
                addMedication()
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
    
    private func addMedication() {
        withAnimation {
            let newMedication = Medication(context: viewContext)
            newMedication.name = name
            if let quantity = Int32(quantity) {
                newMedication.quantity = quantity
            }
            newMedication.id = String(Date().timeIntervalSince1970)
            newMedication.leftQuantity = newMedication.quantity
            newMedication.date = date
            newMedication.repeatPeriod = repeatPeriod
            newMedication.notes = notes
            newMedication.isSelected = false
            newMedication.nextDate = newMedication.date
            
            switch newMedication.repeatPeriod {
            case "Nunca":
                newMedication.repeatSeconds = 15.0
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
    
} //AddMedicationSwiftUIView: View
        
            


        
    

struct AddEditMedicationSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedicationSwiftUIView()
    }
}

