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
    
    var alpha : CGFloat = 1.0
    var alarm: String?
    let dateFormatter = DateFormatter()
    var alarmIsPlaying : Bool = false
    var gradientLayer : CAGradientLayer!
    
    var player : AVQueuePlayer = AudioService.instance.player!
    
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
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        clockBottomConstraint.constant = 8
        MainView.layoutIfNeeded()
        weatherView.alpha = 0
        UIApplication.shared.isIdleTimerDisabled = true
        setBackground()
        setBackgroundFadeImage()
        updateTime()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.updateTime()
            self.checkAlarm()
        }
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)!
            //print(keys["gmKey"]!)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            getCity(lat: latitude, long: longitude)
            //print(latitude, longitude)
        }
    }
    
    func getCity(lat:Double, long:Double)  {
        let apiKey = keys["gmKey"]
        let url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&result_type=postal_code&key=\(apiKey!)"
        //print(url)
        Alamofire.request(url).responseJSON { (responseData) in
            if responseData.result.value != nil {
                let sjVar = JSON(responseData.result.value!)
                self.city = sjVar["results"][0]["address_components"][1]["short_name"].stringValue
            }
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
    
    func setBackgroundFadeImage() {
        let backgroundImageView = UIImageView(image: UIImage(named: "sunrise"))
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
                self.player.play()
                alarmIsPlaying = true
                getWeather()
            }
            
            if weatherView.alpha == 0 {
                
                UIView.animate(withDuration: 1, animations: {
                    self.clockBottomConstraint.constant = 164
                    self.MainView.layoutIfNeeded()
                })
                UIView.animate(withDuration: 1.0, delay: 0.5, animations: {
                    self.weatherView.alpha = 1
                })
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
    @IBAction func settingsBtnPressed(_ sender: Any) {
    }
    
    @IBAction func snoozeBtnPressed(_ sender: Any) {
        shiftAlarmTimeForSnooze()
        snoozeBtn.isHidden = true
        player.pause()
        alarmIsPlaying = false
        UIScreen.main.brightness = 0.33
    }
    
    @IBAction func alarmSwitchChanged(_ sender: Any) {
        snoozeBtn.isHidden = true
        player.pause()
        alarmIsPlaying = false
        alpha = 1.0
        setBackgroundGradientColors(alpha: alpha)
        if activateSwitch.isOn {
            UIView.animate(withDuration: 1) {
                self.weatherView.alpha = 0
                self.clockBottomConstraint.constant = 8
                self.MainView.layoutIfNeeded()
            }
            
        }
        
        
        UIScreen.main.brightness = 0.33
    }
}

