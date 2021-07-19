//
//  AddEditMedicationSwiftUIView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 17/01/21.
//

import SwiftUI
import NotificationCenter



struct AddMedicationSwiftUIView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var quantity = ""
    @State private var date = Date()
    @State private var repeatPeriod = ""
    @State private var notes = ""
    @State private var leftQuantity = ""
    @State private var notificationType = ""
    @State var showAlert = false
    
    
    @ObservedObject var userSettings = UserSettings()
    
    var body: some View {
        NavigationView{
            Form {
                TextField("Nome do Medicamento", text: $name).disableAutocorrection(true)
                TextField("Quantidade Restante", text: $leftQuantity).keyboardType(.numberPad)
                TextField("Quantidade na Caixa", text: $quantity).keyboardType(.numberPad)
                Section {
                    notificationTypePicker
                    DatePicker("Data de Início", selection: $date, in: Date()...)
                    Picker(selection: $repeatPeriod, label: Text("Repetir")) {
                        ForEach(RepeatPeriod.periods, id: \.self) { periods in
                            Text(periods).tag(periods)
                        }
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
                                    }).foregroundColor(.white)
                                , trailing:
                                    Button("Salvar", action: {
                                        if addMedication() {
                                            self.presentationMode.wrappedValue.dismiss()
                                            showAlert = false
                                        } else {
                                            showAlert = true
                                        }
                                        
                                    }).foregroundColor(.white)
                                    .alert(isPresented: $showAlert, content: {
                                        let alert = Alert(title: Text("Erro na criação do medicamento"), message: Text("Confira os dados inseridos"), dismissButton: Alert.Button.default(Text("OK")))
                                        return alert
                                    })
            )
        }
    }
    
    private var notificationTypePicker: some View {
        Group {
            Picker(selection: $notificationType, label: Text("Tipo de Notificação")) {
                ForEach(NotificationType.type, id: \.self) { type in
                    Text(type).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .onAppear {
                notificationType = "Após Conclusão"
            }
            if notificationType == "Regularmente" {
                Text("O próximo medicamento será agendando seguindo a data definida")
            } else {
                Text("O próximo medicamento será agendando seguindo a data da última conclusão")
            }
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
    
    private func addMedication() -> Bool {
        withAnimation {
            let newMedication = Medication(context: viewContext)
            newMedication.name = name
            if let leftQuantity = Int32(leftQuantity) {
                newMedication.remainingQuantity = leftQuantity
            }
            if let quantity = Int32(quantity) {
                newMedication.boxQuantity = quantity
            }
            newMedication.id = String(Date().timeIntervalSince1970)
            newMedication.date = date
            newMedication.repeatPeriod = repeatPeriod
            newMedication.notes = notes
            newMedication.isSelected = false
            newMedication.repeatSeconds = convertToSeconds(newMedication.repeatPeriod ?? "")
            newMedication.notificationType = notificationType
            
            let notificationStatus = scheduleNotification(medication: newMedication)
            
            if(notificationStatus) {
                saveContext()
                return true
            } else {
                print("Erro na criação da notificação")
                return false
            }
            
        }
    }
    
    private func convertToSeconds(_ time: String) -> Double {
        var seconds = 3.0
        switch time {
        case "Nunca":
            seconds = 10.0
        case "15 minutos":
            seconds = 900.0
        case "30 minutos":
            seconds = 1800.0
        case "1 hora":
            seconds = 3600.0
        case "2 horas":
            seconds = 7200.0
        case "4 horas":
            seconds = 14400.0
        case "8 horas":
            seconds = 28800.0
        case "12 horas":
            seconds = 43200.0
        case "1 dia":
            seconds = 86400.0
        case "1 semana":
            seconds = 604800.0
        case "1 mês":
            seconds = 2419200.0
        default:
            break
        }
        return seconds
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

