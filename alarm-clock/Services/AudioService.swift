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

class AudioService {
    static let instance = AudioService()
    var player : AVQueuePlayer?
    //var stream : AVPlayer?
    
    init() {
        //let path = Bundle.main.path(forResource: "deck-party", ofType: "mp3")
        let musicFiles = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: "audioFiles")
        var songList : [AVPlayerItem] = []
        for song in musicFiles! {
            songList.append(AVPlayerItem(url: song))
        }
        songList.shuffle()
        //let url = URL(fileURLWithPath: path!)
        //do {
            player = AVQueuePlayer(items: songList)
            player?.volume = 0
            //let playerItem = AVPlayerItem(url: URL(string: "http://listen.shoutcast.com/SorcererRadio-DisneyParkMusic")!)
            //stream = AVPlayer(playerItem: playerItem)
            
            //stream?.rate = 1.0
        //} catch {
       //     print(error)
      //  }
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

