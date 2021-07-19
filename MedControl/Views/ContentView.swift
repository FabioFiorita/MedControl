//
//  ContentView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 17/01/21.
//

import SwiftUI


struct ContentView: View {
    
    let coloredNavAppearance = UINavigationBarAppearance()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showModalAdd = false
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(entity: Medication.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Medication.date, ascending: true)])
    private var medications: FetchedResults<Medication>
    
    
    @ObservedObject var userSettings = UserSettings()
    
    init(){
        UITableView.appearance().backgroundColor = UIColor(Color.clear)
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = UIColor(Color("main"))
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.white)]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.white)]
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
    }
    
    var body: some View {
        TabView {
            NavigationView {
                List {
                    ForEach(medications, id: \.self) { (medication: Medication) in
                        row(forMedication: medication)
                    }
                    .onDelete(perform: deleteMedication)
                }
                .navigationBarTitle(Text(verbatim: "Medicamentos"),displayMode: .inline)
                .navigationBarItems(trailing:
                                        Button(action: {
                                            self.showModalAdd = true
                                        }) {
                                            Image(systemName: "plus").imageScale(.large).foregroundColor(.white)
                                        }.sheet(isPresented: self.$showModalAdd) {
                                            AddMedicationSwiftUIView()
                                        }
                )
                .listStyle(InsetGroupedListStyle())
            }
            .accentColor(.white)
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
    
    
    
    private func deleteMedication(offsets: IndexSet) {
        withAnimation {
            offsets.map{ medications[$0] }.forEach(viewContext.delete)
            saveContext()
            
        }
    }
    
    private func updateQuantity(medication: FetchedResults<Medication>.Element) {
        withAnimation {
            if medication.remainingQuantity > 1 {
                medication.remainingQuantity -= 1
                
                let hist = Historic(context: viewContext)
                hist.dates = medication.date
                hist.medication = medication
                
                //medication.date = Date(timeInterval: medication.repeatSeconds, since: medication.date ?? Date())
                medication.date = Date(timeIntervalSinceNow: medication.repeatSeconds)
                scheduleNotification(medication: medication)
                
            } else {
                viewContext.delete(medication)
            }
            saveContext()
        }
    }
    
    private func scheduleNotification(medication: Medication) {
        
        let content = UNMutableNotificationContent()
        content.title = "Lembrete"
        content.body = "Tomar \(medication.name ?? "Medicamento")"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: medication.repeatSeconds, repeats: false)
        
        let request = UNNotificationRequest(identifier: medication.id!, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    private func checkmark(forMedication medication: Medication) -> some View {
        Image(systemName: "checkmark.circle").font(.system(size: 35, weight: .regular))
            .foregroundColor(medication.isSelected ? Color.green : Color.primary)
            .onTapGesture {
                updateQuantity(medication: medication)
                withAnimation(.easeInOut(duration: 2.0)) {
                    medication.isSelected = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 2)) {
                        medication.isSelected = false
                    }
                }
            }
    }
    private func medicationName(forMedication medication: Medication) -> some View {
        Text(medication.name ?? "Untitled").font(.title)
    }
    private func medicationRemainingQuantity(forMedication medication: Medication) -> some View {
        Group {
            Text("Medicamentos restantes:")
                .font(.body)
                .fontWeight(.light)
            if Double(medication.remainingQuantity) <= Double(medication.boxQuantity) * (userSettings.limitMedication/100.0) {
                Text("\(medication.remainingQuantity)")
                    .font(.body)
                    .fontWeight(.light).foregroundColor(.red)
            } else {
                Text("\(medication.remainingQuantity)").font(.body)
                    .fontWeight(.light)
            }
        }
    }
    private func medicationDate(forMedication medication: Medication) -> some View {
        Text("Proximo: \(medication.date ?? Date() ,formatter: itemFormatter)")
            .font(.body)
            .fontWeight(.light)
    }
    
    private func row(forMedication medication: Medication) -> some View {
        HStack {
            HStack {
                checkmark(forMedication: medication)
                VStack(alignment: .leading, spacing: 5) {
                    medicationName(forMedication: medication)
                    HStack {
                        medicationRemainingQuantity(forMedication: medication)
                    }
                    medicationDate(forMedication: medication)
                }
            }
            Spacer()
            NavigationLink(destination: MedicationDetailSwiftUIView(medication: medication)) {
                EmptyView()
            }.frame(width: 0, height: 0)
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
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
