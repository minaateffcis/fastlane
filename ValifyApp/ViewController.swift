//
//  ViewController.swift
//  ValifyApp
//
//  Created by Mina Atef on 19/08/2021.
//

import UIKit
import Valify
class ViewController: UIViewController ,ValifyImageDelegate{
    
    @IBOutlet weak var userImageView: UIImageView!
  
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func captureImagePressed(_ sender: Any) {
        ValifyInit.shared.delegate = self
        ValifyInit.shared.presentingViewController = self
        ValifyInit.shared.start()
    }
    
    func retriveImage(image: UIImage) {
        userImageView.image = image
    }
    
}

