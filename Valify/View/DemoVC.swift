//
//  CleanNIDVC.swift
//  Valify
//
//  Created by Mina Atef on 14/12/2021.
//

import UIKit
import AVKit
import AVFoundation

class DemoVC: BWWalkthroughPageViewController {


    @IBOutlet weak var avPlayerView: AVPlayerView!
    var delegate : BWWalkthroughViewControllerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        let avPlayer = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "Demo", ofType: "mp4")!))
        avPlayerView.layer.contentsGravity = .resizeAspect
        let castedLayer = avPlayerView.layer as! AVPlayerLayer
        castedLayer.player = avPlayer
        avPlayer.play()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem, queue: nil) { notification in
            avPlayer.seek(to: CMTime.zero)
            avPlayer.play()
           }

    }
    
    
    
    @IBAction func startPressed(_ sender: Any) {
//        dismiss(animated: true)
        delegate.walkthroughCloseButtonPressed?()
    }
    

}

