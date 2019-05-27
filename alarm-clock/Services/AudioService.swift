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
    var player : AVAudioPlayer!
    var streamPlayer : AVPlayer!
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
            player =  try AVAudioPlayer(contentsOf: musicFile!)
            let streamItem = AVPlayerItem(url: URL.init(string: "https://usa15.fastcast4u.com/proxy/wayarena?mp=/1")!)
            streamPlayer =  AVPlayer(playerItem: streamItem)
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
        //streamPlayer.play()
         timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            self.player?.play()
        }
       
    }
    
    func stopDefaultAlarm() {
        //streamPlayer.pause()
        player.pause()
        timer?.invalidate()
    }
    
    
    
    func setMusic(musicList: MPMediaItemCollection) {
        //print("setting music")
        musicPlayer.setQueue(with: musicList)
        musicPlayer.prepareToPlay()
        musicSelected = true
        
        
    }
    
    func saveMusicList(musicList: MPMediaItemCollection) {
        //print("saving music")
        var musicPersistentIds = [String]()
        for item in musicList.items {
            let persistentId = item.persistentID
            musicPersistentIds.append("\(persistentId)")
        }
        
        //let data = NSKeyedArchiver.archivedData(withRootObject: musicItems)
        UserDefaults.standard.set(musicPersistentIds, forKey: "playlist")
    }
    
    func loadSavedMusic() {
        if let musicPersistentIds = UserDefaults.standard.array(forKey: "playlist") as? [String]
        {
            var musicList = [MPMediaItem]()
            for id in musicPersistentIds{
                let predicate = MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyPersistentID)
                let query = MPMediaQuery(filterPredicates: [predicate])
                if let song = query.items?.first {
                    musicList.append(song)
                }
            }
            setMusic(musicList: MPMediaItemCollection(items: musicList))
        } else {
            print("couldn't load playlist")
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

