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
    @StateObject private var notificationManager = NotificationManager()
    let medication: Medication
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var date = Date()
    @State private var repeatPeriod = ""
    @State private var notes = ""
    @State private var leftQuantity = ""
    @State private var notificationType = ""
    @State var showAlert = false
    @State private var pickerView = true
    
    var body: some View {
        NavigationView{
            Form {
                Group {
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
                        .onAppear {
                            pickerView = false
                        }
                    }
                    Section{
                        Text("Notas")
                        TextEditor(text: $notes).padding()
                    }
                }
                .onAppear {
                    if pickerView {
                        self.name = self.medication.name != nil ? "\(self.medication.name!)" : ""
                        self.leftQuantity = (self.medication.remainingQuantity != 0) ? "\(self.medication.remainingQuantity)" : ""
                        self.quantity = (self.medication.boxQuantity != 0) ? "\(self.medication.boxQuantity)" : ""
                        self.date = self.medication.date ?? Date()
                        self.repeatPeriod = self.medication.repeatPeriod ?? "Nunca"
                        self.notes = self.medication.notes != nil ? "\(self.medication.notes!)" : ""
                    }
                }
            }
            .navigationBarTitle(Text("Editar Medicamento"),displayMode: .inline)
            .navigationBarItems(leading:
                                    Button("Cancelar", action: {
                                        self.presentationMode.wrappedValue.dismiss()
                                    }).foregroundColor(.white)
                                , trailing:
                                    Button("Salvar", action: {
                                        if editMedication(newMedication: medication) {
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
                if pickerView {
                    notificationType = medication.notificationType ?? "Após Conclusão"
                }
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
    
    private func editMedication(newMedication: Medication) -> Bool {
        withAnimation {
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
            
            guard let timeInterval = newMedication.date?.timeIntervalSinceNow else {return false}
            if timeInterval > 0 {
                notificationManager.createLocalNotificationByTimeInterval(identifier: newMedication.id ?? UUID().uuidString, title: "Tomar \(newMedication.name ?? "Medicamento")", timeInterval: timeInterval) { error in
                    if error == nil {
                        print("Notificação criada")
                    }
                }
            }
            saveContext()
            return true
        }
    }
    
    private func convertToSeconds(_ time: String) -> Double {
        var seconds = 3.0
        switch time {
        case "Nunca":
            seconds = 60.0
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
