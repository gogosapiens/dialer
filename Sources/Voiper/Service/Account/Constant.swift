import Foundation

public struct Constant {
    public static let newPushNotification = Notification.Name("new.push.notification")
    public static let openChatNotification = Notification.Name("open.chat.notification")
    public static let startCallIntentNotification = NSNotification.Name(rawValue: "startCallItentNotification")
    public static let lowBalancePushNotification = Notification.Name("new.push.lowBalancePushNotification")
    public static let bannerAnimateNotification = Notification.Name("new.push.bannerAnimateNotification")
    public static let reloadBadges = NSNotification.Name(rawValue: "reloadBadges")
    public static let updateNotification = Notification.Name("accountUpdateNotification")
    public static let intentHandleKey = "handle"
}
