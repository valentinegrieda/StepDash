import Foundation
import SwiftUI
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    
    private let reminderIdentifier = "stepdash.daily-login-reminder"
    private let deliveryCompletionIdentifier = "stepdash.delivery-completed"
    private let deliveryCompletionFallbackIdentifier = "stepdash.delivery-completion-fallback"
    private let missionCompletionPrefix = "stepdash.mission-completed."
    private let missionCompletionFallbackPrefix = "stepdash.mission-completion-fallback."
    private let reminderEligibleKey = "stepdash.notification.reminderEligible"
    private let lastActiveDateKey = "stepdash.notification.lastActiveDate"
    private let appOpenReminderDelay: TimeInterval = 60
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let identifier = notification.request.identifier
        if isCompletionNotification(identifier) {
            return [.banner, .sound]
        }

        return []
    }
    
    func updateReminderEligibility(hasRegisteredUser: Bool) {
        defaults.set(hasRegisteredUser, forKey: reminderEligibleKey)
        
        if !hasRegisteredUser {
            clearReminder()
        } else {
            requestAuthorizationIfNeeded { _ in }
        }
    }
    
    func handleScenePhase(_ phase: ScenePhase) {
        switch phase {
        case .active:
            defaults.set(Date(), forKey: lastActiveDateKey)
            clearReminder()
            clearStaleMissionCompletionNotifications()
            clearStaleDeliveryCompletionFallbacks()
        case .background:
            scheduleReminderIfPossible()
            printNotificationDebugState()
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

    func scheduleMissionCompletionFallback(
        missionID: Int,
        title: String,
        currentValue: Double,
        goalValue: Double,
        unitPerStep: Double
    ) {
        guard goalValue > 0 else { return }

        let remainingValue = max(0, goalValue - currentValue)
        let remainingSteps = remainingValue / max(unitPerStep, 0.01)
        let estimatedSeconds = max(5, min((remainingSteps / 100) * 60, 86_400))

        requestAuthorizationIfNeeded { [weak self] granted in
            guard granted else { return }
            self?.enqueueMissionCompletion(
                identifier: self?.missionCompletionFallbackIdentifier(for: missionID),
                title: title,
                timeInterval: estimatedSeconds
            )
        }
    }

    func notifyMissionCompleted(missionID: Int, title: String) {
        cancelMissionCompletionNotification(missionID: missionID)

        requestAuthorizationIfNeeded { [weak self] granted in
            guard granted else { return }
            self?.enqueueMissionCompletion(
                identifier: self?.missionCompletionIdentifier(for: missionID),
                title: title,
                timeInterval: 1
            )
        }
    }

    func cancelMissionCompletionNotification(missionID: Int) {
        let identifiers = [
            missionCompletionIdentifier(for: missionID),
            missionCompletionFallbackIdentifier(for: missionID),
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    func clearStaleMissionCompletionNotifications() {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let identifiers = requests
                .map(\.identifier)
                .filter { self.isMissionCompletionNotification($0) }

            guard !identifiers.isEmpty else { return }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }

        notificationCenter.getDeliveredNotifications { [weak self] notifications in
            guard let self else { return }
            let identifiers = notifications
                .map(\.request.identifier)
                .filter { self.isMissionCompletionNotification($0) }

            guard !identifiers.isEmpty else { return }
            self.notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
        }
    }

    func notifyDeliveryCompletedIfNeeded(recipient: String, dayKey: Date, goalSteps: Int) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [
            deliveryCompletionIdentifier,
            deliveryCompletionFallbackIdentifier,
        ])

        requestAuthorizationIfNeeded { [weak self] granted in
            guard granted else { return }
            self?.enqueueCompletionNotification(
                identifier: self?.deliveryCompletionIdentifier,
                title: "Delivery finish",
                body: "Delivery to \(recipient) already achieved. Open StepDash to claim your reward.",
                timeInterval: 1
            )
        }
    }

    func clearStaleDeliveryCompletionFallbacks() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [deliveryCompletionFallbackIdentifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [deliveryCompletionFallbackIdentifier])
    }

    func printNotificationDebugState() {
        notificationCenter.getNotificationSettings { settings in
            print("Notification authorization:", settings.authorizationStatus.rawValue)
        }

        notificationCenter.getPendingNotificationRequests { requests in
            print("Pending notifications:", requests.map(\.identifier))
        }
    }
    
    private func enqueueReminder() {
        let content = UNMutableNotificationContent()
        content.title = "StepDash is waiting"
        content.body = "Open again and continue today's mission."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: appOpenReminderDelay,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: reminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error {
                print("Failed to schedule app-open reminder:", error)
            }
        }
    }
    
    private func clearReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminderIdentifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [reminderIdentifier])
    }

    private func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            guard let self else {
                completion(false)
                return
            }

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .notDetermined:
                self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion(granted)
                }
            case .denied:
                completion(false)
            @unknown default:
                completion(false)
            }
        }
    }

    private func enqueueMissionCompletion(identifier: String?, title: String, timeInterval: TimeInterval) {
        enqueueCompletionNotification(
            identifier: identifier,
            title: "Mission is finished",
            body: "\(title) has been achieved. Open StepDash to claim your reward.",
            timeInterval: timeInterval
        )
    }

    private func missionCompletionIdentifier(for missionID: Int) -> String {
        "\(missionCompletionPrefix)\(missionID)"
    }

    private func missionCompletionFallbackIdentifier(for missionID: Int) -> String {
        "\(missionCompletionFallbackPrefix)\(missionID)"
    }

    private func isMissionCompletionNotification(_ identifier: String) -> Bool {
        identifier.hasPrefix(missionCompletionPrefix)
            || identifier.hasPrefix(missionCompletionFallbackPrefix)
    }

    private func isCompletionNotification(_ identifier: String) -> Bool {
        identifier == deliveryCompletionIdentifier
            || identifier == deliveryCompletionFallbackIdentifier
            || isMissionCompletionNotification(identifier)
    }

    private func enqueueCompletionNotification(
        identifier: String?,
        title: String,
        body: String,
        timeInterval: TimeInterval,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard let identifier else {
            completion?(false)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, timeInterval),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error {
                print("Failed to schedule completion notification:", error)
                completion?(false)
                return
            }

            completion?(true)
        }
    }
}
