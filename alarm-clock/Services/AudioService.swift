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
    var player : AVAudioPlayer?
    
    init() {
        let path = Bundle.main.path(forResource: "deck-party", ofType: "mp3")
        let url = URL(fileURLWithPath: path!)
        do {
            try player = AVAudioPlayer(contentsOf: url)
            player?.volume = 0
        } catch {
            print(error)
        }
    }
    

        
}
