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
    @IBOutlet weak var nightModeButton: UIButton!
    
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
    enum BackgroundType : String {
        case image, movie
    }
    
    var backgroundType = BackgroundType.image
    let midnight = #colorLiteral(red: 0.01176470588, green: 0.1529411765, blue: 0.2274509804, alpha: 1) //#03273A
    let weatherService = WeatherService.instance
    var musicWithVideo = true
    
    //var keys : NSDictionary = [:]
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait,.portraitUpsideDown]
    }

   override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        clock.font = clock.font.withSize(UIScreen.main.bounds.width * 0.30)
        
        clockBottomConstraint.constant = 8
        MainView.layoutIfNeeded()
        weatherView.alpha = 0
        UIApplication.shared.isIdleTimerDisabled = true
        setAlarmOverlay()
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
        
        setBackgroundFadeImage()
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        if UIDevice.current.orientation.isLandscape {
//            print("now in landscape")
//        }
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if gradientLayer != nil {
            gradientLayer.frame = view.bounds
        }
    }
    
    func setBackgroundGradientColors(alpha: CGFloat = 1.0) {
        gradientLayer.removeAnimation(forKey: "colorChange")
        gradientLayer.colors = [UIColor.black.withAlphaComponent(alpha).cgColor, midnight.withAlphaComponent(alpha).cgColor ,UIColor.black.withAlphaComponent(alpha).cgColor]
        gradientLayer.locations = [0.2, 0.5, 1]
    }
    
    func setGradientFadeSpeed() {
        let fadeSpeed = getFadeSpeed()
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = CFTimeInterval(fadeSpeed)
        gradientChangeAnimation.toValue = [UIColor.black.withAlphaComponent(0).cgColor, midnight.withAlphaComponent(0).cgColor ,UIColor.black.withAlphaComponent(0).cgColor]
        gradientChangeAnimation.fillMode = .forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientLayer.add(gradientChangeAnimation, forKey: "colorChange")
    }
    
    func setAlarmOverlay() {
        gradientLayer = CAGradientLayer()
        setBackgroundGradientColors()
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
    }

   
    func setBackgroundFadeImage() {
        print("setting background")
        view.sendSubviewToBack(backgroundMovieView)
        view.sendSubviewToBack(backgroundImageView)
        if let movieData = UserDefaults.standard.object(forKey: "movie") as? Data {
            print("found a movie")
            backgroundType = BackgroundType.movie
            setMovieAsBackgroundLayer(data: movieData)
            return
        }
        print("setting an image")
        backgroundImageView.image = UIImage(named: "sunrise")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.isHidden = false
        backgroundMovieView.isHidden = true
        
        if let imgData = UserDefaults.standard.object(forKey: "bgImage") as? Data {
            let selectedImage = NSKeyedUnarchiver.unarchiveObject(with: imgData) as! UIImage
            
            backgroundImageView.image = selectedImage
            
        }
        
        backgroundType = BackgroundType.image
    }
    
    func setMovieAsBackgroundLayer(data: Data) {
        print("setting movie background")
        backgroundImageView.isHidden = true
        backgroundMovieView.isHidden = false
        backgroundMovieView.layer.sublayers = nil

        let movieUrl = NSKeyedUnarchiver.unarchiveObject(with: data) as! URL
        //print("stored movie url: ", movieUrl)
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        //print("docPath: ", docPath)
        let videoUrl = URL(fileURLWithPath: docPath.appendingFormat("/backgroundVideo.mp4"))
        //print("videoUrl: ", videoUrl)
        let playerItem = AVPlayerItem(url: videoUrl as URL)
        //print("playerItem error: ", playerItem.error ?? "none")
        
        moviePlayer = AVQueuePlayer(items: [playerItem])
        
        playerLayer = AVPlayerLayer(player: moviePlayer)
        playerLayer.frame = backgroundMovieView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        
        playerLooper = AVPlayerLooper(player: moviePlayer!, templateItem: playerItem)
        backgroundMovieView.layer.addSublayer(playerLayer)
        //print("movie view sublayers: ", backgroundMovieView.layer.sublayers!.count)
        backgroundType = BackgroundType.movie
        
        moviePlayer?.seek(to: CMTime.zero)
        
    }
    
//    @objc func loopVideo() {
//        print("looping movie")
//        moviePlayer?.seek(to: .zero)
//        moviePlayer?.play()
//    }
    
    func getTimeAsString(time: Int? = Int(Date().timeIntervalSince1970)) -> String {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let dateStr = dateFormatter.string(from: Date(timeIntervalSince1970: Double(time!)))
        return dateStr
    }
    
    func checkAlarm() {
        if activateSwitch.isOn && (getTimeAsString() == alarm || alarmIsPlaying) {
            
            if !alarmIsPlaying {
                if backgroundType == BackgroundType.movie {
                    moviePlayer?.play()
                    if let musicWithVideoValue = UserDefaults.standard.object(forKey: "musicWithVideo")  {
                        musicWithVideo = musicWithVideoValue as! Bool
                    }
                    if musicWithVideo {
                        audioService.play()
                    }
                } else {
                    audioService.play()
                }
                alarmIsPlaying = true
                updateWeather()
                
                setGradientFadeSpeed()
                //let fadeSpeed = getFadeSpeed()
                
//                Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { (timer) in
//                    self.alpha -= fadeSpeed
//                    self.setBackgroundGradientColors(alpha: self.alpha )
//                }
            }
            
            if weatherView.alpha == 0 {
                
                UIView.animate(withDuration: 1, animations: {
                    self.clockBottomConstraint.constant = 120
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
                nightModeButton.isHidden = true
            }
//            if alpha > 0 {
//                alpha -= getFadeSpeed()
//                setBackgroundGradientColors(alpha: alpha)
//            }
//            if player.volume < 1 {
//                player.volume += 0.01
//            }
            if UIScreen.main.brightness < 0.75 {
                UIScreen.main.brightness += 0.01
            }
        }
    }
    
    func getFadeSpeed() -> CGFloat {
        
        var fadeSpeedIndex = 1
        if let fadeSpeedSavedValue = UserDefaults.standard.object(forKey: "fadeSpeed") {
            fadeSpeedIndex = fadeSpeedSavedValue as! Int
        }
        print("fade speed index: " , fadeSpeedIndex)
        if fadeSpeedIndex == 0 {
            return 15.0
        }
        return fadeSpeedIndex == 1 ? 30.0 : 60.0
        
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
        // Text is attributed to include a small line height, so need to copy the text
        // with all existing attributes and update the text value.  clock.text will replace
        // it with a plain text object
        let mutableCopy = clock.attributedText?.mutableCopy() as! NSMutableAttributedString
        mutableCopy.mutableString.setString(dateFormatter.string(from: now))
        clock.attributedText = mutableCopy
        
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
        df.dateFormat = "E MMM dd, yyyy"
        //df.dateStyle = .medium
        //df.timeStyle = .none
        dateLbl.text = df.string(from: Date())
        
    }
    
    @IBAction func settingsBtnPressed(_ sender: Any) {
    }
    
    @IBAction func snoozeBtnPressed(_ sender: Any) {
        shiftAlarmTimeForSnooze()
        snoozeBtn.isHidden = true
        nightModeButton.isHidden = false
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
        nightModeButton.isHidden = !activateSwitch.isOn
    }
    @IBAction func nightModeButtonPressed(_ sender: Any) {
        UIScreen.main.brightness = 0
        nightModeButton.isHidden = true
    }
}

