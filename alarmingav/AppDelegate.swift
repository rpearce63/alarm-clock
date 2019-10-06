//
//  AppDelegate.swift
//  alarm-clock
//
//  Created by Rick Pearce on 4/27/18.
//  Copyright © 2018 Rick Pearce. All rights reserved.
//

import UIKit
import AVFoundation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    var audioSession: AVAudioSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
         audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession!.setCategory(AVAudioSession.Category.playback, options: [.mixWithOthers])
        } catch {
            print("Unable to set audioSession")
        }
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            if !granted {
                print("not granted")
            }
        }
        
        return true
    }
    
    func sendNotification() {
        if let alarm = UserDefaults.standard.string(forKey: "alarm") {
            print("setting notification")
            print(alarm)
            
            let content = UNMutableNotificationContent()
            
            content.title = "Wake up!"
            content.body = "Time to get up!"
            //content.sound = .default
            content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: "audioFiles/DCL-Chime-Long.mp3"))
            
            let alarmDate = getDateFromString(strDate: alarm)
            
            
            let triggerTime = Calendar.current.dateComponents([.hour, .minute, .second], from:   alarmDate)
            print(triggerTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerTime, repeats: false)
            let requestIdentifier = "alarmNotification"
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
            
            notificationCenter.add(request) { (error) in
                if (error != nil) {
                    print("could not trigger notification")
                }
            }
            
//            print("alarmDate: ", alarmDate)
//
//            let components = Calendar.current.dateComponents([.timeZone,.year, .day, .hour, .minute], from: Date())
//            let day = components.day
//            let hour = components.hour
//            let minute = components.minute
//            print("Components: ", components)
//            var newTriggerDate = Date()
//            var triggerComponents = DateComponents()
//            triggerComponents.timeZone = TimeZone(abbreviation: "GMT")
//            triggerComponents.hour = triggerTime.hour
//            triggerComponents.minute = triggerTime.minute
//            triggerComponents.year = components.year!
//
//            if hour! <= triggerTime.hour!  &&  minute! <= triggerTime.minute! {
//
//                triggerComponents.day = day
//            } else {
//                triggerComponents.day = day! + 1
//            }
//
//            print("triggerComponents: ", triggerComponents)
//            let targetCalendar = Calendar.current
//            newTriggerDate = targetCalendar.date(from: triggerComponents)!
//            print("newTriggerDate: ", newTriggerDate)
//            let timer = Timer(fireAt: newTriggerDate, interval: 0, target: self, selector: #selector(playAlarm), userInfo: nil, repeats: false)
//            RunLoop.main.add(timer, forMode: .common)
        }
    }

    @objc func playAlarm() {
        print("playing alarm")
        let musicFile = Bundle.main.url(forResource: "DCL-Chime-Long", withExtension: "mp3", subdirectory: "audioFiles")
        let player = try! AVAudioPlayer(contentsOf: musicFile!)
        player.prepareToPlay()
        player.play()
    }
    
    
    func getDateFromString(strDate : String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        df.timeZone = .current
        return df.date(from: strDate)!
        
    }
    
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return [.portrait, .portraitUpsideDown]
//    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        AudioService.instance.pause()
        
        sendNotification()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        AudioService.instance.pause()
    }


}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
