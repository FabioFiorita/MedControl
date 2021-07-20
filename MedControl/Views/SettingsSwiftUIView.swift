//
//  SettingsSwiftUIView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 20/01/21.
//

import SwiftUI

struct SettingsSwiftUIView: View {
    
    @ObservedObject var userSettings = UserSettings()
    @State private var showModalTutorial = false
    @Environment(\.openURL) var openURL
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray5).ignoresSafeArea(.all)
                VStack(alignment: .leading, spacing: 50.0) {
                    VStack(alignment: .leading, spacing: 5.0) {
                        medicationAlertSettings
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10.0)
                    links
                    Spacer()
                }
                .navigationBarTitle("Ajustes")
                .padding()
                .cornerRadius(10.0)
            }
        }
    }
    private var medicationAlertSettings: some View {
        Group {
            Toggle(isOn: $userSettings.limitNotification) {
                Text("Deseja ser notificado quando estiver acabando seus remédios?")
            }
            Stepper(value: $userSettings.limitMedication, in: 0.0...100.0) {
                Text("Começar a notificar quando a quantidade chegar em: ") + Text("\(Int(userSettings.limitMedication))%").foregroundColor(.red).bold() + Text(" do total")
            }
            DatePicker("Horario para as notificações:", selection: $userSettings.limitDate, displayedComponents: .hourAndMinute)
        }
    }
    
    private var links: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            HStack {
                Button(action: {
                    openURL(URL(string: "https://github.com/FabioFiorita/MedControl")!)
                }) {
                    Text("Avalie!")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.gray)
                }
            }
            Divider()
            HStack {
                Button(action: {
                    self.showModalTutorial = true
                }) {
                    Text("Tutorial")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.gray)
                }.sheet(isPresented: self.$showModalTutorial) {
                    TutorialSwiftUIView()
                }
                
            }
            Divider()
            HStack {
                Button(action: {
                    openURL(URL(string: "https://github.com/FabioFiorita/MedControl")!)
                }) {
                    Text("Código-Fonte")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.gray)
                }
            }
            Divider()
            HStack {
                Button(action: {
                    EmailHelper.shared.sendEmail(subject: "", body: "", to: "fabiolfp@gmail.com")
                }) {
                    Text("Fale Conosco")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.gray)
                }
                
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10.0)
    }
}


struct SettingsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSwiftUIView()
    }
}
