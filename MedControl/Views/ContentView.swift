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
    @State private var showTimeIntervalAlert = false
    @State private var authorizationDenied = false
    @State private var showModalEdit = false
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(entity: Medication.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Medication.date, ascending: true)])
    private var medications: FetchedResults<Medication>
    @StateObject private var notificationManager = NotificationManager()
    
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
                .onAppear(perform: notificationManager.reloadAuthorizationStatus)
                .onChange(of: notificationManager.authorizationStatus) { authorizationStatus in
                    switch authorizationStatus {
                    case .notDetermined:
                        notificationManager.requestAuthorization()
                    case .authorized:
                        notificationManager.reloadLocalNotifications()
                    case .denied:
                        self.authorizationDenied = true
                    default:
                        break
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    notificationManager.reloadAuthorizationStatus()
                }
                .alert(isPresented: $authorizationDenied) {
                    Alert(
                            title: Text("Notificações desativadas"),
                            message: Text("Abra o App Ajustes e habilite as notificações para monitorar seus medicamentos"),
                            primaryButton: .cancel(Text("Cancelar")),
                            secondaryButton: .default(Text("Abrir Ajustes"), action: {
                              if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                              }
                            }))
                }
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
                
                let historic = Historic(context: viewContext)
                historic.dates = Date()
                historic.medication = medication
                
                rescheduleNotification(forMedication: medication, forHistoric: historic)
            } else {
                viewContext.delete(medication)
            }
            saveContext()
        }
    }
    
    private func rescheduleNotification(forMedication medication: Medication, forHistoric historic: Historic) {
        medicationStatus(forMedication: medication, forHistoric: historic)
        if medication.notificationType == "Regularmente" {
            medication.date = Date(timeInterval: medication.repeatSeconds, since: medication.date ?? Date())
        } else {
            medication.date = Date(timeIntervalSinceNow: medication.repeatSeconds)
        }
        guard let timeInterval = medication.date?.timeIntervalSinceNow else {return}
        guard let identifier = medication.id else {return}
        if timeInterval > 0 {
            notificationManager.deleteLocalNotifications(identifiers: [identifier])
            notificationManager.createLocalNotificationByTimeInterval(identifier: identifier, title: "Tomar \(medication.name ?? "Medicamento")", timeInterval: timeInterval) { error in
                if error == nil {}
            }
        } else {
            historic.medicationStatus = "Não tomou"
            self.showTimeIntervalAlert = true
        }
    }
    
    private func medicationStatus(forMedication medication: Medication, forHistoric historic: Historic) {
        var timeIntervalComparation = 0.0
        if let timeIntervalDate = medication.date?.timeIntervalSince(historic.dates ?? Date()) {
            timeIntervalComparation = timeIntervalDate
        }
        if timeIntervalComparation < -10.0 {
            historic.medicationStatus = "Atrasado"
        } else {
            historic.medicationStatus = "Sem Atraso"
        }
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
            .alert(isPresented: $showTimeIntervalAlert, content: {
                Alert(
                        title: Text("Erro na hora de agendar a notificação"),
                        message: Text("A próxima notificação foi agendada para o próximo horário da repetição a partir da hora atual"),
                        primaryButton: .cancel(Text("Cancelar")),
                        secondaryButton: .default(Text("Editar Medicamento")) {
                            self.showModalEdit = true
                        }
                )
            })
            .sheet(isPresented: $showModalEdit) {
                EditMedicationSwiftUIView(medication: medication)
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
