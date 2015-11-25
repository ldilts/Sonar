//
//  AppDelegate.swift
//  Sonar
//
//  Created by Lucas Michael Dilts on 11/22/15.
//  Copyright © 2015 Lucas Dilts. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    var window: UIWindow?
    
    var deviceTokenStr = ""
    
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
//    let subscriptionTopic = "/topics/global"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
//        if !NSUserDefaults.standardUserDefaults().boolForKey("NotificationsSetup") {
            // [START_EXCLUDE]
            // Configure the Google context: parses the GoogleService-Info.plist, and initializes
            // the services that have entries in the file
            var configureError:NSError?
            GGLContext.sharedInstance().configureWithError(&configureError)
            assert(configureError == nil, "Error configuring Google services: \(configureError)")
            gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
            // [END_EXCLUDE]
            
            // Register for remote notifications
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            // [END register_for_remote_notifications]
        
            // [START start_gcm_service]
            let gcmConfig = GCMConfig.defaultConfig()
            gcmConfig.receiverDelegate = self
            GCMService.sharedInstance().startWithConfig(gcmConfig)
            // [END start_gcm_service]
            
//        }
        
        
        
        let baseURL: NSURL = NSURL(string: "http://192.168.0.148:8000/")!
        
        startRestkitWithBaseURL(baseURL)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        GCMService.sharedInstance().disconnect()
        // [START_EXCLUDE]
        self.connectedToGCM = false
        // [END_EXCLUDE]
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Connect to the GCM server to receive non-APNS notifications
        GCMService.sharedInstance().connectWithHandler({
            (NSError error) -> Void in
            if error != nil {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                print("Connected to GCM")
                // [START_EXCLUDE]
                self.subscribeToTopic()
                // [END_EXCLUDE]
            }
        })
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
//        self.deviceTokenStr = convertDeviceTokenToString(deviceToken)
        
        // [START get_gcm_reg_token]
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
            kGGLInstanceIDAPNSServerTypeSandboxOption:true]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
        // [END get_gcm_reg_token]
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "NotificationsSetup")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("\nDevice token for push notifications: FAIL -- ")
        print(error.description + "\n")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("\nNotification received: \(userInfo)\n")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        // Handle the received message
        // [START_EXCLUDE]
        NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
            userInfo: userInfo)
        // [END_EXCLUDE]
    }
    
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
        fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
            print("\nNotification received: \(userInfo)\n")
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            // Handle the received message
            // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
            // [START_EXCLUDE]
            NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                userInfo: userInfo)
            handler(UIBackgroundFetchResult.NoData);
            // [END_EXCLUDE]
    }
    
//    private func convertDeviceTokenToString(deviceToken:NSData) -> String {
//        //  Convert binary Device Token to a String (and remove the <,> and white space charaters).
//        var deviceTokenStr = deviceToken.description.stringByReplacingOccurrencesOfString(">", withString: "")
//        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString("<", withString: "")
//        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(" ", withString: "")
//        
//        // Our API returns token in all uppercase, regardless how it was originally sent.
//        // To make the two consistent, I am uppercasing the token string here.
//        deviceTokenStr = deviceTokenStr.uppercaseString
//        return deviceTokenStr
//    }
    
    // [START on_token_refresh]
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    // [END on_token_refresh]
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        }
    }
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {

            let httpClient: AFHTTPClient = AFHTTPClient(baseURL: NSURL(string: "http://192.168.0.148:8000"))
            httpClient.parameterEncoding = AFJSONParameterEncoding
            httpClient.registerHTTPOperationClass(AFJSONRequestOperation)
            
            print("\n\(self.deviceTokenStr)\n")
            
            let parameter = ["dev_id": "241120152203", "dev_type": "IOS", "reg_id": "\(self.registrationToken!)"]
            
            httpClient.postPath("devices/", parameters: parameter, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                self.subscribedToTopic = true;
                print("\nSuccess!!\n")
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    print("\n\(error.description)\n")
                    
            })
            
//            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic,
//                options: nil, handler: {(NSError error) -> Void in
//                    if (error != nil) {
//                        // Treat the "already subscribed" error more gently
//                        if error.code == 3001 {
//                            print("Already subscribed to \(self.subscriptionTopic)")
//                        } else {
//                            print("Subscription failed: \(error.localizedDescription)");
//                        }
//                    } else {
//                        self.subscribedToTopic = true;
//                        
//                    }
//            })
        }
    }
    
}

