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
    @StateObject private var delegate = NotificationDelegate()
    @ObservedObject var userSettings = UserSettings()
    @StateObject private var medicationManager = MedicationManager()
    @AppStorage("TutorialView") var isWalkthroughViewShowing = true
    
    init(){
        //UITableView.appearance().backgroundColor = UIColor(colorScheme == .dark ? Color.black : Color(.systemGray6))
        coloredNavAppearance.configureWithOpaqueBackground()
        coloredNavAppearance.backgroundColor = UIColor(Color("main"))
        coloredNavAppearance.titleTextAttributes = [.foregroundColor: UIColor(Color.white)]
        coloredNavAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.white)]
        UINavigationBar.appearance().standardAppearance = coloredNavAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredNavAppearance
    }
    
    var body: some View {
        Group {
            if isWalkthroughViewShowing {
                TutorialSwiftUIView(isWalkthroughViewShowing: $isWalkthroughViewShowing)
            } else {
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
                        .onAppear(perform: {
                            notificationManager.reloadAuthorizationStatus()
                            UNUserNotificationCenter.current().delegate = delegate
                        })
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
        }
    }
    
    
    private func deleteMedication(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let medication = medications[index]
                medicationManager.deleteMedication(medication: medication, viewContext: viewContext)
            }
        }
    }
    
    
    private func updateQuantity(medication: FetchedResults<Medication>.Element) {
        withAnimation {
            let sucess = medicationManager.updateRemainingQuantity(medication: medication, viewContext: viewContext)
            if !sucess {
                self.showTimeIntervalAlert = true
            }
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
                    message: Text("Configure a Data de início novamente"),
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
