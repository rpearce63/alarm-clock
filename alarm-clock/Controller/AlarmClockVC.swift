//
//  ViewController.swift
//  alarm-clock
//
//  Created by Rick Pearce on 4/27/18.
//  Copyright © 2018 Rick Pearce. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import SwiftyJSON
import CoreLocation

class AlarmClockVC: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var clock: UILabel!
    @IBOutlet weak var activateSwitch: UISwitch!
    @IBOutlet weak var alarmLbl: UILabel!
    @IBOutlet weak var snoozeBtn: UIButton!
    @IBOutlet weak var forecastLbl: UILabel!
    @IBOutlet weak var tempHighLbl: UILabel!
    @IBOutlet weak var tempLowLbl: UILabel!
    @IBOutlet weak var currentWxLbl: UILabel!
    @IBOutlet weak var weatherView: UIStackView!
    @IBOutlet weak var clockBottomConstraint: NSLayoutConstraint!
    @IBOutlet var MainView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var weatherOverlay: UIView!
    
    var alpha : CGFloat = 1.0
    var alarm: String?
    let dateFormatter = DateFormatter()
    var alarmIsPlaying : Bool = false
    var gradientLayer : CAGradientLayer!
    var audioService : AudioService = AudioService.instance
    var player : AVAudioPlayer = AudioService.instance.player!
    
    
    let locationManager = CLLocationManager()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var city : String = ""
    var keys : NSDictionary = [:]
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UserDefaults.standard.removeObject(forKey: "playlist")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.startUpdatingLocation()
        
        clockBottomConstraint.constant = 8
        MainView.layoutIfNeeded()
        weatherView.alpha = 0
        UIApplication.shared.isIdleTimerDisabled = true
        setBackground()
        setBackgroundFadeImage()
        updateTime()
        updateDate()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.updateTime()
            self.updateDate()
            self.checkAlarm()
        }
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)!
            //print(keys["gmKey"]!)
        }
        audioService.loadSavedMusic()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            //getCity(lat: latitude, long: longitude)
            lookUpCurrentLocation { (location) in
                self.city = location?.locality ?? ""
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location update failed: \(error.localizedDescription)")
    }
    
//    func getCity(lat:Double, long:Double)  {
//        let apiKey = keys["gmKey"]
//        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&result_type=postal_code&key=\(apiKey!)"
//        //print(url)
//        Alamofire.request(url).responseJSON { (responseData) in
//            if responseData.result.value != nil {
//                let sjVar = JSON(responseData.result.value!)
//                self.city = sjVar["results"][0]["address_components"][1]["short_name"].stringValue
//            }
//        }
//
//    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
        -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(
                lastLocation,
                completionHandler: { (placemarks, error) in
                    if error == nil {
                        let firstLocation = placemarks?[0]
                        completionHandler(firstLocation)
                    }
                    else {
                        // An error occurred during geocoding.
                        completionHandler(nil)
                    }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarm = UserDefaults.standard.object(forKey: "alarm") as? String
        if alarm != nil {
            alarmLbl.text = alarm
        } else {
            alarmLbl.text = "No Alarm Set"
        }
        updateBackgroundImage()
    }
    
    
    func setBackgroundGradientColors(alpha: CGFloat = 1.0) {
        let midnight = #colorLiteral(red: 0.01176470588, green: 0.1529411765, blue: 0.2274509804, alpha: 1) //#03273A
        gradientLayer.colors = [UIColor.black.withAlphaComponent(alpha).cgColor, midnight.withAlphaComponent(alpha).cgColor ,UIColor.black.withAlphaComponent(alpha).cgColor]
        gradientLayer.locations = [0.2, 0.5, 1]
    }
    
    func setBackground() {
        gradientLayer = CAGradientLayer()
        setBackgroundGradientColors()
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    func updateBackgroundImage() {
        let bgView = self.view.subviews.first as! UIImageView
        
        if let imgData = UserDefaults.standard.object(forKey: "bgImage") as? Data {
            let selectedImage = NSKeyedUnarchiver.unarchiveObject(with: imgData) as! UIImage
            bgView.image = selectedImage
        }
    }
    
    func setBackgroundFadeImage() {
        let backgroundImageView = UIImageView(image: UIImage(named: "sunrise"))
        if let imgData = UserDefaults.standard.object(forKey: "bgImage") as? Data {
            let selectedImage = NSKeyedUnarchiver.unarchiveObject(with: imgData) as! UIImage
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.image = selectedImage
        }
        
        backgroundImageView.frame = view.bounds
        view.insertSubview(backgroundImageView, at: 0)
    }
    
    func getTimeAsString(time: Int? = Int(Date().timeIntervalSince1970)) -> String {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let dateStr = dateFormatter.string(from: Date(timeIntervalSince1970: Double(time!)))
        return dateStr
    }
    
    func checkAlarm() {
        if activateSwitch.isOn && (getTimeAsString() == alarm || alarmIsPlaying) {
            
            if !alarmIsPlaying {
                audioService.play()
                alarmIsPlaying = true
                getWeather()
            }
            
            if weatherView.alpha == 0 {
                
                UIView.animate(withDuration: 1, animations: {
                    self.clockBottomConstraint.constant = 160
                    self.MainView.layoutIfNeeded()
                })
                UIView.animate(withDuration: 1.0, delay: 0.5, animations: {
                    self.weatherView.alpha = 1
                })
                UIView.animate(withDuration: 30.0, delay: 0.5, animations: {
                    self.weatherOverlay.alpha = 0.4
                    
                }) {_ in
                    self.forecastLbl.textColor = .white
                    self.currentWxLbl.textColor = .white
                    self.tempHighLbl.textColor = .white
                    self.tempLowLbl.textColor = .white
                }
                
            }
            
            if snoozeBtn.isHidden {
                snoozeBtn.isHidden = false
            }
            if alpha > 0 {
                alpha -= 0.01
                setBackgroundGradientColors(alpha: alpha)
            }
            if player.volume < 1 {
                player.volume += 0.01
            }
            if UIScreen.main.brightness < 0.75 {
                UIScreen.main.brightness += 0.01
            }
        }
    }
    
    func shiftAlarmTimeForSnooze() {
        var time = dateFormatter.date(from: self.alarm!)
        time?.addTimeInterval(9 * 60)
        self.alarm = dateFormatter.string(from: time!)
    }
    
    func updateTime() {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        
        let now = Date()
        clock.text = dateFormatter.string(from: now)
    }

    func getWeather()  {
        locationManager.requestLocation()
        Alamofire.request( "https://api.darksky.net/forecast/719e207be3ba45829aeadc5594f8d363/\(latitude),\(longitude)")
            .validate()
            .responseJSON { (responseData) in
                //print(responseData)
                if((responseData.result.value) != nil) {
                    let swiftyJsonVar = JSON(responseData.result.value!)
                    self.forecastLbl.text =  swiftyJsonVar["daily"]["data"][0]["summary"].stringValue
                    self.tempHighLbl.text = "\(swiftyJsonVar["daily"]["data"][0]["temperatureHigh"].intValue)"
                    self.tempLowLbl.text = "\(swiftyJsonVar["daily"]["data"][0]["temperatureLow"].intValue)"
                    self.currentWxLbl.text = "Currently \(swiftyJsonVar["currently"]["summary"].stringValue) and \(swiftyJsonVar["currently"]["temperature"].intValue) in \(self.city)"
                }
        }
        
    }
    
    func updateDate()  {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        dateLbl.text = df.string(from: Date())
        
    }
    
    @IBAction func settingsBtnPressed(_ sender: Any) {
    }
    
    @IBAction func snoozeBtnPressed(_ sender: Any) {
        shiftAlarmTimeForSnooze()
        snoozeBtn.isHidden = true
        audioService.pause()
        alarmIsPlaying = false
        UIScreen.main.brightness = 0.33
    }
    
    @IBAction func alarmSwitchChanged(_ sender: Any) {
        snoozeBtn.isHidden = true
        audioService.pause()
        alarmIsPlaying = false
        alpha = 1.0
        setBackgroundGradientColors(alpha: alpha)
        
        UIView.animate(withDuration: 1) {
            self.weatherOverlay.alpha = 0
            if self.activateSwitch.isOn {
                self.weatherView.alpha = 0
                self.clockBottomConstraint.constant = 8
                self.MainView.layoutIfNeeded()
            }
        }
        audioService.loadSavedMusic()
        
        UIScreen.main.brightness = 0.33
    }
}

