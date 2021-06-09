//
//  SettingsSwiftUIView.swift
//  MedControl
//
//  Created by Fabio Fiorita on 20/01/21.
//

import SwiftUI

struct SettingsSwiftUIView: View {
    
    @ObservedObject var userSettings = UserSettings()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 5.0) {
                Toggle(isOn: $userSettings.limitNotification) {
                    Text("Deseja ser notificado quando estiver acabando seus remédios?")
                }
                Stepper(value: $userSettings.limitMedication, in: 0.0...100.0) {
                    Text("Começar a notificar quando a quantidade chegar em: ") + Text("\(Int(userSettings.limitMedication))%").foregroundColor(.red).bold() + Text(" do total")
                }
                DatePicker("Horario para as notificações:", selection: $userSettings.limitDate, displayedComponents: .hourAndMinute)
                Spacer()
                
            }.navigationBarTitle("Ajustes")
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10.0)
        }
        
    }
}

struct SettingsSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsSwiftUIView()
    }
}
