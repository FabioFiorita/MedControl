//
//  MedicationDetailSwiftUIView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 17/01/21.
//

import SwiftUI
import CoreData
import WebKit

struct MedicationDetailSwiftUIView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var showModal = false
    
    let medication: Medication
    
    
    
    
    var body: some View {
        
        
        NavigationView{
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading, spacing: 5.0){
                    Text("Medicamentos restantes: \(medication.leftQuantity)")
                    
                        Text("Quantidade de medicamentos na caixa: \(medication.quantity)")
                        Button(action: {
                            refreshQuantity(medication)
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Renovar Medicamentos")
                                .frame(width:350, height: 40, alignment: .center)
                                .background(Color("main"))
                                .cornerRadius(10.0)
                                .foregroundColor(.white)
                        }
                }.padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10.0)
                
                if medication.notes != "" {
                    VStack(alignment: .leading, spacing: 5.0){
                        Text("Notas").font(.title2)
                        Text("\(medication.notes ?? "")").frame(width:350, height: 40, alignment: .center)
                    }.padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10.0)
                }
                
                WebView(url: "https://consultaremedios.com.br/b/\(medication.name ?? "")")
                Spacer()
            }
            .navigationBarTitle("\(medication.name ?? "Medicamento")", displayMode: .large)
            
        }
        
        .navigationBarItems(trailing: Button(action: {
            self.showModal = true
        }) {
            Text("Editar")
        }.sheet(isPresented: self.$showModal) {
            EditMedicationSwiftUIView(medication: medication)
        }
        )
    }
    
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
    private func refreshQuantity(_ medication: FetchedResults<Medication>.Element) {
        withAnimation {
            
            medication.leftQuantity += medication.quantity
            
            saveContext()
        }
    }
    
//    private func refreshNotifications(medication: Medication) {
//        
//    }
}

struct MedicationDetailSwiftUIView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let medication = Medication(context: moc)
        
        return NavigationView {
            MedicationDetailSwiftUIView(medication: medication)
        }
    }
}
