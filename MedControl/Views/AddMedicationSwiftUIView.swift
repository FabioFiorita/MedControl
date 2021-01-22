//
//  AddEditMedicationSwiftUIView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 17/01/21.
//

import SwiftUI

struct RepeatPeriod{
    static let periods = [
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
    
    var body: some View {
        NavigationView{
        Form {
            
                TextField("Nome do Medicamento", text: $name)
                TextField("Quantidade", text: $quantity).keyboardType(.numberPad)
            
                DatePicker("Data", selection: $date)
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
            newMedication.leftQuantity = newMedication.quantity
            newMedication.date = date
            newMedication.repeatPeriod = repeatPeriod
            newMedication.notes = notes
            
            saveContext()
        }
       
    }
}

struct AddEditMedicationSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedicationSwiftUIView()
    }
}
