//
//  SettingsSwiftUIView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 20/01/21.
//

import SwiftUI
import StoreKit

struct SettingsSwiftUIView: View {
    
    @ObservedObject var userSettings = UserSettings()
    @State private var showModalTutorial = false
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    @State private var isWalkthroughViewShowing = false
    
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(colorScheme == .dark ? .systemBackground : .systemGray6)
                ScrollView {
                    VStack(alignment: .leading, spacing: 50.0) {
                        VStack(alignment: .leading, spacing: 5.0) {
                            medicationAlertSettings
                        }
                        .padding()
                        .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
                        .cornerRadius(10.0)
                        links
                        policies
                        Spacer()
                    }
                    .navigationBarTitle("Ajustes")
                    .padding()
                    .cornerRadius(10.0)
                }
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
        VStack(alignment: .leading, spacing: 15.0) {
            Button(action: {
                if let scene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }) {
                Text("Avalie!")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
            }
            Divider()
            HStack {
                NavigationLink("Tutorial", destination: TutorialSwiftUIView(isWalkthroughViewShowing: $isWalkthroughViewShowing))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
                
                
            }
            Divider()
            Button(action: {
                openURL(URL(string: "https://github.com/FabioFiorita/MedControl")!)
            }) {
                Text("Código-Fonte")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
            }
            Divider()
            Button(action: {
                EmailHelper.shared.sendEmail(subject: "", body: "", to: "fabiolfp@gmail.com")
            }) {
                Text("Fale Conosco")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
            }
            
            
            
        }
        .padding()
        .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
        .cornerRadius(10.0)
    }
    private var policies: some View {
        VStack(alignment: .leading, spacing: 15.0) {
            Button(action: {
                openURL(URL(string: "https://raw.githubusercontent.com/FabioFiorita/MedControl/main/Terms%20%26%20Conditions")!)
            }) {
                Text("Termos de Uso")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
            }
            Divider()
            Button(action: {
                openURL(URL(string: "https://raw.githubusercontent.com/FabioFiorita/MedControl/main/Terms%20%26%20Conditions")!)
            }, label: {
                Text("Política de Privacidade")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray)
            })
        }
        .padding()
        .background(Color(colorScheme == .dark ? .systemGray6 : .systemBackground))
        .cornerRadius(10.0)
    }
}


struct SettingsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSwiftUIView()
    }
}
