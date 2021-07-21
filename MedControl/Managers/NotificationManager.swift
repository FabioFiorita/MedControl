//
//  NotificationManager.swift
//  MedControl
//
//  Created by Fabio Fiorita on 19/07/21.
//

import Foundation
import UserNotifications

final class NotificationManager: ObservableObject {
    @Published private(set) var notifications: [UNNotificationRequest] = []
    @Published private(set) var authorizationStatus: UNAuthorizationStatus?
    
    func reloadAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, _ in
            DispatchQueue.main.async {
                self.authorizationStatus = isGranted ? .authorized : .denied
            }
        }
    }
    
    func reloadLocalNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            DispatchQueue.main.async {
                self.notifications = notifications
            }
        }
    }
    
    func createLocalNotificationByDateMatching(identifier: String, title: String, hour: Int, minute: Int, completion: @escaping (Error?) -> Void) {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.sound = .default
        notificationContent.body = "Abra o App para encontrar as farmácias mais próximas!"
        
        let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: completion)
        print("Notificação: \(identifier) e titulo \(notificationContent.title) criada!")
    }
    
    func createLocalNotificationByTimeInterval(identifier: String, title: String, timeInterval: Double, completion: @escaping (Error?) -> Void) {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.sound = .default
        notificationContent.body = "Abra o App para tomar o Medicamento!"
        
        let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: completion)
        //print("Notificação: \(identifier) e titulo \(notificationContent.title) criada!")
    }
    
    func deleteLocalNotifications(identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        //print("Notificação: \(identifiers.first ?? "") deletada!")
    }
}

class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge,.banner,.sound])
    }
}
