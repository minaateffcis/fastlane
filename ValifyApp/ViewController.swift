//
//  ViewController.swift
//  ValifyApp
//
//  Created by Mina Atef on 19/08/2021.
//

import UIKit
import Valify
import AVFoundation
class ViewController: UIViewController ,ValifyImageDelegate{
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var speedOfMovingUpwords: UITextField!
    @IBOutlet weak var numberOfImagesInAutoMoving: UITextField!
    private var player: AVAudioPlayer?
    @IBOutlet weak var speedOfMovingDownwards: UITextField!
    var upwardsSpeed = 4
    var downwardsSpeed = 8
    var numberOfImages = 30
    override func viewDidLoad() {
        super.viewDidLoad()
//        playSound()
    }
    
    
    
    
    
    func startWatermark(){
            ValifyInit.shared.delegate = self
            ValifyInit.shared.presentingViewController = self
            ValifyInit.shared.numberOfImages =  4
            ValifyInit.shared.upwardSpeed =  4
            ValifyInit.shared.downwardSpeed = 8
            ValifyInit.shared.watermarkType = .frontCapture
            ValifyInit.shared.start()
    }
    
 
    
    override func viewDidAppear(_ animated: Bool) {
//        startWatermark()
    }
    
    func showAlert(message:String){
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func boomButtonTouchedUpInside(_ sender: Any) {
//           let arr = [1, 2, 3]
//           let elem = arr[4]
       }


    
    func restartWatermark(watermarkType:WatermarkType?) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) {[self] in
            ValifyInit.shared.delegate = self
            ValifyInit.shared.presentingViewController = self
            ValifyInit.shared.numberOfImages =  4
            ValifyInit.shared.upwardSpeed =  4
            ValifyInit.shared.downwardSpeed =  8
            ValifyInit.shared.watermarkType = watermarkType
            ValifyInit.shared.start()
        }
//        userImageView.image = image

    }
    
    @IBAction func autoJumpingPressed(_ sender: Any) {
        ValifyInit.shared.delegate = self
        ValifyInit.shared.presentingViewController = self
        ValifyInit.shared.numberOfImages =  4
        ValifyInit.shared.upwardSpeed =  4
        ValifyInit.shared.downwardSpeed =  8
        ValifyInit.shared.watermarkType = .frontCapture
        ValifyInit.shared.start()
        
    }
    
    @IBAction func autoMovingPressed(_ sender: Any) {
        ValifyInit.shared.delegate = self
        ValifyInit.shared.presentingViewController = self
        ValifyInit.shared.numberOfImages =  4
        ValifyInit.shared.upwardSpeed = 4
        ValifyInit.shared.downwardSpeed =  8
        ValifyInit.shared.watermarkType = .backCapture
        ValifyInit.shared.start()
    }
    
}

extension UIViewController{
    func dismissKey()
    {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false; view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard()
    {
    view.endEditing(true)
    }
}







