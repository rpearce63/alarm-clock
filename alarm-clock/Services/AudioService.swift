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
    
    func player() -> AVAudioPlayer {
        let path = Bundle.main.path(forResource: "deck-party", ofType: "mp3")
        let url = URL(fileURLWithPath: path!)
        var alarmMusic = AVAudioPlayer()
        do {
            try alarmMusic = AVAudioPlayer(contentsOf: url)
        } catch {
            print(error)
        }
        return alarmMusic
    }
}
