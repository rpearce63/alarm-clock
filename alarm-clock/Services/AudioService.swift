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

class AudioService {
    static let instance = AudioService()
    var player : AVQueuePlayer?
    var musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    init() {
        let musicFiles = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "audioFiles")
        var songList : [AVPlayerItem] = []
        for song in musicFiles! {
            songList.append(AVPlayerItem(url: song))
        }
        songList.shuffle()
        
        player = AVQueuePlayer(items: songList)
        player?.volume = 0
        musicPlayer.shuffleMode = MPMusicShuffleMode.songs
    }
    
    func setMusic(musicList: MPMediaItemCollection) {
        musicPlayer.setQueue(with: musicList)
        
    }
    
    func saveMusicList(musicList: MPMediaItemCollection) {
        let filePath = getDocumentDirectory().appendingPathComponent("playlist")
        //print(filePath)
        do {
            let data = NSKeyedArchiver.archivedData(withRootObject: musicList)
            try data.write(to: filePath)
            UserDefaults.standard.set(data, forKey: "playlist")
        } catch {
            print("couldn't write file")
        }
        
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadSavedMusic() {
        if let musicData = UserDefaults.standard.object(forKey: "playlist") as? Data
            
              {
                let musicList =  (NSKeyedUnarchiver.unarchiveObject(with: musicData) as? MPMediaItemCollection)!
            setMusic(musicList: musicList)
             
                
        } else {
            print("couldn't load playlist")
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

