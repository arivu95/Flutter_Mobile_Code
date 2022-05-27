import UIKit
import Flutter
import GoogleMaps
import flutter_voip_push_notification
import flutter_call_kit
import PushKit
import CallKit
import Firebase
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, PKPushRegistryDelegate {
    
    var voipRegistry: PKPushRegistry?
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyA_76M-Sca9mXdpkJKVHSeUkFRgvvQ3icI")
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    self.voipRegistration()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  // Handle incoming pushes
    public func pushRegistry(_ registry: PKPushRegistry,
                             didReceiveIncomingPushWith payload: PKPushPayload,
                             for type: PKPushType,
                             completion: @escaping () -> Swift.Void){
        
        FlutterVoipPushNotificationPlugin.didReceiveIncomingPush(with: payload, forType: type.rawValue)
        
        let signalType = payload.dictionaryPayload["signal_type"] as! String
        if(signalType == "endCall" || signalType == "rejectCall"){
            return
        }
        
        let uuid = payload.dictionaryPayload["session_id"] as! String
        let uID = payload.dictionaryPayload["caller_id"] as! Int
        let callerName = payload.dictionaryPayload["caller_name"] as! String
        let isVideo = payload.dictionaryPayload["call_type"] as! Int == 1;
        FlutterCallKitPlugin.reportNewIncomingCall(
            uuid,
            handle: String(uID),
            handleType: "generic",
            hasVideo: isVideo,
            localizedCallerName: callerName,
            fromPushKit: true
        )
        completion()
    }
    
    // Handle updated push credentials
    public func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        // Process the received pushCredentials
        FlutterVoipPushNotificationPlugin.didUpdate(pushCredentials, forType: type.rawValue);
    }
    
    // Register for VoIP notifications
    func voipRegistration(){
        // Create a push registry object
        voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        // Set the registry's delegate to self
        voipRegistry!.delegate = self
        // Set the push type to VoIP
        voipRegistry!.desiredPushTypes = [PKPushType.voIP]
    }
}
