//
//  UserSettings.swift
//  MedControl
//
//  Created by Fabio Fiorita on 01/02/21.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var limitMedication: Double {
            didSet {
                UserDefaults.standard.set(limitMedication, forKey: "limitMedication")
            }
        }
    @Published var limitNotification: Bool {
            didSet {
                UserDefaults.standard.set(limitNotification, forKey: "limitNotification")
            }
        }
    @Published var limitDate: Date {
            didSet {
                UserDefaults.standard.set(limitDate, forKey: "limitDate")
            }
        }
    
    
        init() {
            self.limitMedication = UserDefaults.standard.object(forKey: "limitMedication") as? Double ?? 20.0
            self.limitNotification = UserDefaults.standard.object(forKey: "limitNotification") as? Bool ?? true
            self.limitDate = UserDefaults.standard.object(forKey: "limitDate") as? Date ?? Date()
        }
    }

