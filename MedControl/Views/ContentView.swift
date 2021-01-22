//
//  ContentView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 17/01/21.
//

import SwiftUI


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showModalAdd = false
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Medication.date, ascending: true)])
    private var medications: FetchedResults<Medication>
    
    var body: some View {
        TabView {
            NavigationView {
                List {
                    ForEach(medications, id: \.self) { (medication: Medication) in
                        HStack {
                            HStack {
                                Image(systemName: "checkmark.circle").font(.system(size: 35, weight: .regular)).onTapGesture {
                                    updateQuantity(medication)
                                }
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(medication.name ?? "Untitled").font(.title)
                                    Text("Medicamentos restantes: \(medication.leftQuantity)")
                                        .font(.body)
                                        .fontWeight(.light)
                                    Text("Proximo: \(medication.date ?? Date(),formatter: itemFormatter)")
                                        .font(.body)
                                        .fontWeight(.light)
                                }
                            }
                            Spacer()
                            NavigationLink(destination: MedicationDetailSwiftUIView(medication: medication)) {
                                EmptyView()
                            }.frame(width: 0, height: 0)
                                
                        }
                            
                    }.onDelete(perform: deleteMedication)
                } // List
                .navigationBarTitle(Text(verbatim: "Medicamentos"),displayMode: .inline)
                .navigationBarItems(trailing:
                    Button(action: {
                        self.showModalAdd = true
                        
                    }) {
                        Image(systemName: "plus").imageScale(.large)
                        }.sheet(isPresented: self.$showModalAdd) {
                            AddMedicationSwiftUIView()
                        }
                )
                .listStyle(GroupedListStyle())
                
        }// Navigation View
            .tabItem {
                    Image(systemName: "pills")
                    Text("Medicamentos")
                  }
            MapSwiftUIView()
            .tabItem {
                    Image(systemName: "map")
                    Text("Mapa")
                  }
            SettingsSwiftUIView()
            .tabItem {
                    Image(systemName: "gear")
                    Text("Ajustes")
                  }
        }// TabView
    }// Body
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
    
    
    
    private func deleteMedication(offsets: IndexSet) {
        withAnimation {
            offsets.map{ medications[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func updateQuantity(_ medication: FetchedResults<Medication>.Element) {
        withAnimation {
            if medication.leftQuantity > 1 {
                medication.leftQuantity -= 1
            } else {
                viewContext.delete(medication)
            }
            saveContext()
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt-BR")
        return formatter
    }()
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
