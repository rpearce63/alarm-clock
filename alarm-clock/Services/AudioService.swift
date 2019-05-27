//
//  AudioService.swift
//  alarm-clock
//
//  Created by Helen Pearce on 4/28/18.
//  Copyright © 2018 Rick Pearce. All rights reserved.
//

import Foundation
import AVFoundation
import AVKit
import MediaPlayer
import AudioToolbox

class AudioService {
    static let instance = AudioService()
    var player : AVAudioPlayer?
    let musicPlayer = MPMusicPlayerController.systemMusicPlayer
    var musicSelected : Bool = false
    var soundId: SystemSoundID = 1324
    var timer: Timer?
    
    init() {
        let musicFile = Bundle.main.url(forResource: "DCL-Chime", withExtension: "mp3", subdirectory: "audioFiles")
        //let song = AVPlayerItem(url: musicFile)
        //var songList : [AVPlayerItem] = []
        //for song in musicFiles! {
            //songList.append(AVPlayerItem(url: song))
        //}
        //songList.shuffle()
        do {
            player = try AVAudioPlayer(contentsOf: musicFile!)
        } catch {
            print("could not load file")
        }
            //player?.volume = 0
        musicPlayer.shuffleMode = MPMusicShuffleMode.songs
        
        
    }
    func play() {
        musicSelected ? musicPlayer.play() : playDefaultAlarm()
        
    }
    
    func pause() {
        musicSelected ? musicPlayer.pause() : stopDefaultAlarm()
    }
    
    func playDefaultAlarm() {
         timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            self.player?.play()
        }
        
    }
    func stopDefaultAlarm() {
        player?.pause()
        timer?.invalidate()
    }
    
    
    
    func setMusic(musicList: MPMediaItemCollection) {
        //print("setting music")
        musicPlayer.setQueue(with: musicList)
        musicPlayer.prepareToPlay()
        
        
    }
    
    func saveMusicList(musicList: MPMediaItemCollection) {
        //print("saving music")
        let data = NSKeyedArchiver.archivedData(withRootObject: musicList)
        UserDefaults.standard.set(data, forKey: "playlist")
    }
    
//    func getDocumentDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths[0]
//    }
    
    func loadSavedMusic() {
        if let musicData = UserDefaults.standard.object(forKey: "playlist") as? Data
        {
            let musicList =  (NSKeyedUnarchiver.unarchiveObject(with: musicData) as? MPMediaItemCollection)!
            setMusic(musicList: musicList)
            musicSelected = true
        } else {
            //print("couldn't load playlist")
            musicSelected = false
        }
        
    }
        
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

