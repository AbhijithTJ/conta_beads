import UIKit
import Flutter
import FirebaseMessaging // Ensure Firebase natively receives the token

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // FIX: Register plugins synchronously during app launch
    GeneratedPluginRegistrant.register(with: self)
    
    // Set UNUserNotificationCenter delegate for local notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // DEBUG: Catch successful APNs registration
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("🍎 [NATIVE iOS] Successfully registered with APNs. Token: \(token)")
    
    // Explicitly pass token to Firebase (redundant if swizzling works, but guarantees delivery)
    Messaging.messaging().apnsToken = deviceToken
    
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // DEBUG: Catch failed APNs registration (CRITICAL FOR DEBUGGING)
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("🍎 [NATIVE iOS] FAILED to register for APNs: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
