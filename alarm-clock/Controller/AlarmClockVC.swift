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

class AlarmClockVC: UIViewController {

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
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundMovieView: UIView!
    
    var alpha : CGFloat = 1.0
    var alarm: String?
    let dateFormatter = DateFormatter()
    var alarmIsPlaying : Bool = false
    var gradientLayer : CAGradientLayer!
    var audioService : AudioService = AudioService.instance
    var moviePlayer : AVQueuePlayer?
    var playerLooper: NSObject?
    var playerLayer: AVPlayerLayer!
    //var movieView : UIView!
    
    var backgroundType = "image"

    let weatherService = WeatherService.instance
    
    //var keys : NSDictionary = [:]
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        clockBottomConstraint.constant = 8
        MainView.layoutIfNeeded()
        weatherView.alpha = 0
        UIApplication.shared.isIdleTimerDisabled = true
        setBackground()
        //setBackgroundFadeImage()
        updateTime()
        updateDate()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            self.updateTime()
            self.updateDate()
            self.checkAlarm()
        }
        
        audioService.loadSavedMusic()
        
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        alarm = UserDefaults.standard.object(forKey: "alarm") as? String
        if alarm != nil {
            alarmLbl.text = alarm
        } else {
            alarmLbl.text = "No Alarm Set"
        }
        //updateBackgroundImage()
        setBackgroundFadeImage()
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
//    func updateBackgroundImage() {
//        if backgroundType == "movie" {
//            setBackgroundFadeImage()
//            return
//        }
//        print("setting image as background")
//        if let bgView = self.view.subviews.first as? UIImageView{
//
//            if let imgData = UserDefaults.standard.object(forKey: "bgImage") as? Data {
//                let selectedImage = NSKeyedUnarchiver.unarchiveObject(with: imgData) as! UIImage
//                bgView.image = selectedImage
//            }
//
//        }
//    }
    
    func setBackgroundFadeImage() {
        view.sendSubviewToBack(backgroundMovieView)
        view.sendSubviewToBack(backgroundImageView)
        if let movieData = UserDefaults.standard.object(forKey: "movie") as? Data {
            backgroundType = "movie"
            setMovieAsBackgroundLayer(data: movieData)
            return
        }

        backgroundImageView.image = UIImage(named: "sunrise")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.isHidden = false
        backgroundMovieView.isHidden = true
        
        if let imgData = UserDefaults.standard.object(forKey: "bgImage") as? Data {
            let selectedImage = NSKeyedUnarchiver.unarchiveObject(with: imgData) as! UIImage
            
            backgroundImageView.image = selectedImage
            
        }
        
        backgroundType = "image"
    }
    
    func setMovieAsBackgroundLayer(data: Data) {
        print("setting movie background")
        backgroundImageView.isHidden = true
        backgroundMovieView.isHidden = false
        
        let movieUrl = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSURL
        //print("stored movie url: ", movieUrl)
        
        let playerItem = AVPlayerItem(url: movieUrl as URL)
        moviePlayer = AVQueuePlayer(items: [playerItem])
        
        playerLayer = AVPlayerLayer(player: moviePlayer)
        playerLayer.frame = backgroundMovieView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        
        playerLooper = AVPlayerLooper(player: moviePlayer!, templateItem: playerItem)
        backgroundMovieView.layer.addSublayer(playerLayer)
        
        backgroundType = "movie"
        
        moviePlayer?.seek(to: CMTime.zero)
        
    }
    
    @objc func loopVideo() {
        print("looping movie")
        moviePlayer?.seek(to: .zero)
        moviePlayer?.play()
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
                updateWeather()
                if backgroundType == "movie" {
                    print("playing movie")
                    moviePlayer?.play()
                }
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
                alpha -= 0.02
                setBackgroundGradientColors(alpha: alpha)
            }
//            if player.volume < 1 {
//                player.volume += 0.01
//            }
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

    func updateWeather()  {
        weatherService.getWeather() { response in
            
            self.forecastLbl.text =  response["daily"]["data"][0]["summary"].stringValue
            self.tempHighLbl.text = "\(response["daily"]["data"][0]["temperatureHigh"].intValue)"
            self.tempLowLbl.text = "\(response["daily"]["data"][0]["temperatureLow"].intValue)"
            self.currentWxLbl.text = "Currently \(response["currently"]["summary"].stringValue) and \(response["currently"]["temperature"].intValue) in \(self.weatherService.city!)"
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
        
        moviePlayer?.pause()
        
        alarmIsPlaying = false
        UIScreen.main.brightness = 0.33
    }
    
    @IBAction func alarmSwitchChanged(_ sender: Any) {
        snoozeBtn.isHidden = true
        audioService.pause()
        moviePlayer?.pause()
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

