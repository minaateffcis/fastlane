//
//  AVPlayerView.swift
//  Valify
//
//  Created by Mina Atef on 15/12/2021.
//

import UIKit
import AVFoundation
class AVPlayerView: UIView {

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

}
