import Foundation
import SwiftUI
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    
    private let reminderIdentifier = "stepdash.daily-login-reminder"
    private let reminderEligibleKey = "stepdash.notification.reminderEligible"
    private let lastActiveDateKey = "stepdash.notification.lastActiveDate"
    
    private init() {}
    
    func updateReminderEligibility(hasRegisteredUser: Bool) {
        defaults.set(hasRegisteredUser, forKey: reminderEligibleKey)
        
        if !hasRegisteredUser {
            clearReminder()
        }
    }
    
    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            defaults.set(Date(), forKey: lastActiveDateKey)
            scheduleReminderIfPossible()
        case .background:
            scheduleReminderIfPossible()
        default:
            break
        }
    }
    
    func scheduleReminderIfPossible() {
        guard defaults.bool(forKey: reminderEligibleKey) else {
            clearReminder()
            return
        }
        
        clearReminder()
        
        notificationCenter.getNotificationSettings { [weak self] settings in
            guard let self else { return }
            
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self.enqueueReminder()
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    guard granted else { return }
                    self.enqueueReminder()
                }
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func enqueueReminder() {
        let content = UNMutableNotificationContent()
        content.title = "StepDash miss you"
        content.body = "You haven't open StepDash for a while. Continue your steps today."
        content.sound = .default
        
        // Notification will pop up tomorrow
        // Uncomment this if you want to test it
        //        let trigger = UNCalendarNotificationTrigger(
        //            dateMatching: nextReminderDateComponents(from: Date()),
        //            repeats: false
        //        )
        
        // Quick testing for user notifications
        // Notification will pop up after 5 se conds
        // Uncomment this if you want to test it
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request)
    }
    
    private func clearReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [reminderIdentifier])
    }
    
    private func nextReminderDateComponents(from now: Date) -> DateComponents {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now.addingTimeInterval(86_400)
        let reminderDate = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: nextDay) ?? nextDay
        
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminderDate)
    }
}
