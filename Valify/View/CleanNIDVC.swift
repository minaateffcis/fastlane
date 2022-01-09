//
//  CleanNIDVC.swift
//  Valify
//
//  Created by Mina Atef on 14/12/2021.
//

import UIKit
import AVKit
import AVFoundation

class CleanNIDVC: BWWalkthroughPageViewController {

    @IBOutlet weak var viewoView: UIView!
    @IBOutlet weak var gifImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "cleanNID", ofType: "mp4")!))
        let layer = AVPlayerLayer(player: player)
                layer.frame = view.bounds
                layer.videoGravity = .resizeAspectFill
        viewoView.layer.addSublayer(layer)
                player.volume = 0
                player.play()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { notification in
            player.seek(to: CMTime.zero)
            player.play()
           }

    }
    
    

}

