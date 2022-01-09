//
//  Sounds.swift
//  Valify
//
//  Created by Mina @ Valify on 21/12/2021.
//

import Foundation
import AVFoundation

class Sounds{
    private var player: AVAudioPlayer?
    
    var audioPlayer = AVAudioPlayer()
    var bundle = Bundle(for: PhotoViewController.self)

    func playSounds(soundName:String) throws {
        let url = bundle.url(forResource: soundName, withExtension: "mp3")!
        
        audioPlayer = try AVAudioPlayer(contentsOf: url)
//        audioPlayer.prepareToPlay()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
        do {
              try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [AVAudioSession.CategoryOptions.mixWithOthers])
//            DispatchQueue.global().async {
                self.audioPlayer.play()
//            }
                    
            } catch {
                print("")
//              Utility.sharedInstance.debugprint("err")
            }
        
//        }
        
    }
    
//    var player: AVAudioPlayer?

    func playSound(){
        guard let url = Bundle.main.url(forResource: "SuccessSFX", withExtension: "mp3") else {
            print("MP3 resource not found.")
            return
        }

        print("Music to play : \(String(describing: url))")
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }

    }

    func playSound(soundName:String) {
        
            guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }

            do {
//                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//                try AVAudioSession.sharedInstance().setActive(true)
                
//
                    player = try AVAudioPlayer(contentsOf: url)
                    guard let player = player else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                    player.play()
                }

                /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
                

                /* iOS 10 and earlier require the following line:
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

//                guard let player = player else { return }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    player.play()
//                }

            } catch let error {
                print(error.localizedDescription)
            }
        
//        DispatchQueue,dela
        
    }
    
//    func playSound(){
//        var player: AVAudioPlayer?
//        let sound = Bundle.main.url(forResource: "Horn", withExtension: "mp3")
//        do {
//            player = try AVAudioPlayer(contentsOf: sound!)
//            guard let player = player else { return }
//            player.prepareToPlay()
//            player.play()
//        } catch let error {
//            print(error.localizedDescription)
//        }

//    }
}
