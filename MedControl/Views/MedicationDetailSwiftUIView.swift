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
    @Environment(\.colorScheme) var colorScheme
    @State private var showModal = false
    
    let medication: Medication
    private var sortedHistoric: [Historic] {
        var aux = Array(medication.dates as? Set<Historic> ?? [])
        aux = aux.sorted(by: { $0.dates ?? .distantPast > $1.dates ?? .distantPast })
        return aux
    }
    @State private var historicCount = 7
    
    var body: some View {
        NavigationView{
            ZStack {
                Color(colorScheme == .dark ? .systemBackground : .systemGray6)
                VStack(alignment: .leading) {
                    VStack {
                        VStack(alignment: .leading, spacing: 5.0){
                            medicationInformation(forMedication: medication)
                        }
                        .padding()
                        .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
                        .cornerRadius(10.0)
                        
                        medicationNotes(forMedication: medication)
                        stepperHistory
                    }.padding()
                    //.background(Color(.systemBackground))
                    List {
                        ForEach(sortedHistoric.prefix(historicCount) , id: \.self){ historic in
                            medicationDateHistory(forHistoric: historic)
                        }
                    }
                    Spacer()
                }
                
            }
            
            .navigationBarTitle("\(medication.name ?? "Medicamento")", displayMode: .inline)
            
        }// MARK: NavigationView
        .navigationBarItems(trailing: Button(action: {
            self.showModal = true
        }) {
            Text("Editar").foregroundColor(.white)
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
            
            medication.remainingQuantity += medication.boxQuantity
            
            saveContext()
        }
    }
    
    private func medicationInformation(forMedication medication: Medication) -> some View {
        Group {
            Text("Medicamentos restantes: \(medication.remainingQuantity)")
            Text("Quantidade de medicamentos na caixa: \(medication.boxQuantity)")
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
        }
    }
    private func medicationNotes(forMedication medication: Medication) -> some View {
        Group {
            if medication.notes != "" {
                VStack(alignment: .leading, spacing: 5.0){
                    Text("Notas").font(.title2)
                    Text("\(medication.notes ?? "")").frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                        .padding()
                }.padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10.0)
            }
        }
    }
    private func medicationDateHistory(forHistoric historic: Historic) -> some View {
        Group {
            HStack {
                Text("\(historic.dates ?? Date(),formatter: itemFormatter)" )
                Spacer()
                Group {
                    switch historic.medicationStatus {
                    case "Sem Atraso":
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    case "Atrasado":
                        Image(systemName: "clock.fill").foregroundColor(.yellow)
                    case "Não tomou":
                        Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                    default:
                        Image(systemName: "questionmark").foregroundColor(.red)
                    }
                }
                
            }
        }
    }
    private var stepperHistory : some View {
            Stepper(value: $historicCount, in: 0...31) {
                Text("Mostrar últimos ") + Text("\(historicCount)").bold().foregroundColor(.orange) + Text(" medicamentos")
            }
            .padding()
            .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
            .cornerRadius(10.0)
        
    }
    
    
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
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
