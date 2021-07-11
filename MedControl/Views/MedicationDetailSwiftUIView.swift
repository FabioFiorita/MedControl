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
    private var arrayDate: [Historic] {
        let aux = Array(medication.dates as? Set<Historic> ?? [])
        return aux
    }
    private var sortedDates: [Historic] {
        let aux = arrayDate.sorted(by: { $0.dates!.timeIntervalSinceNow > $1.dates!.timeIntervalSinceNow })
        return aux
    }
    
    var body: some View {
        NavigationView{
            ZStack {
                Color("main").ignoresSafeArea(.all)
                VStack(alignment: .leading) {
                    VStack {
                        VStack(alignment: .leading, spacing: 5.0){
                            Text("Medicamentos restantes: \(medication.leftQuantity)")
                            
                                Text("Quantidade de medicamentos na caixa: \(medication.quantity)")
                                Button(action: {
                                    refreshQuantity(medication)
                                    self.presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Renovar Medicamentos")
                                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                        .padding()
                                        .background(Color("main"))
                                        .cornerRadius(10.0)
                                        .foregroundColor(.white)
                                }
                        }//MARK: VStack
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10.0)
                        
                        if medication.notes != "" {
                            VStack(alignment: .leading, spacing: 5.0){
                                Text("Notas").font(.title2)
                                Text("\(medication.notes ?? "")").frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                    .padding()
                            }.padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10.0)
                        }

                    }.padding()
                    
                    List {
                        ForEach(sortedDates.prefix(10) , id: \.self){ hist in
                            HStack {
                                Text("\(hist.dates ?? Date(),formatter: itemFormatter)" )
                                Spacer()
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                            }
                            
                        }
                    }
                    
                    Spacer()
                }// MARK: VStack
                
            }
            
            .navigationBarTitle("\(medication.name ?? "Medicamento")", displayMode: .large)
            
        }// MARK: NavigationView
        .navigationBarItems(trailing: Button(action: {
            self.showModal = true
        }) {
            Text("Editar")
        }.sheet(isPresented: self.$showModal) {
            EditMedicationSwiftUIView(medication: medication)
        }
        )
    }//MARK: Body

    
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
    

}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "pt-BR")
    return formatter
}()

struct MedicationDetailSwiftUIView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let medication = Medication(context: moc)
        
        return NavigationView {
            MedicationDetailSwiftUIView(medication: medication)
        }
    }
}
