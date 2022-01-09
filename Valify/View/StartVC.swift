//
//  StartVC.swift
//  Valify
//
//  Created by Mina Atef on 15/12/2021.
//

import UIKit

class StartVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                   self.showWalkthrough()
               }
    }


}


extension StartVC: BWWalkthroughViewControllerDelegate{
   
    
    func showWalkthrough(){
        
        // Get view controllers and build the walkthrough
        
        let walkthrough = self.storyboard?.instantiateViewController(withIdentifier: "walk") as! BWWalkthroughViewController
        
        let demoVC = self.storyboard?.instantiateViewController(withIdentifier: "walk4") as! DemoVC
        demoVC.delegate = self
//        let page_zero = stb.instantiateViewController(withIdentifier: "walk0")
        guard let page_one = self.storyboard?.instantiateViewController(withIdentifier: "walk1") else{
            return
        }
        guard let page_two = self.storyboard?.instantiateViewController(withIdentifier: "walk2") else{
            return
        }
        guard let page_three = self.storyboard?.instantiateViewController(withIdentifier: "walk3") else{
            return
        }
        guard let page_four = self.storyboard?.instantiateViewController(withIdentifier: "walk4") else{
            return
        }
        
        // Attach the pages to the master
//        walkthrough.delegate = self
        walkthrough.add(viewController:page_one)
        walkthrough.add(viewController:page_two)
        walkthrough.add(viewController:page_three)
        walkthrough.add(viewController:page_four)
        walkthrough.modalPresentationStyle = .fullScreen
        self.present(walkthrough, animated: true, completion: nil)
    }
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
        print("Current Page \(pageNumber)")
    }
    
    func walkthroughCloseButtonPressed() {
        print("dd")
//        self.dismiss(animated: true, completion: nil)
        if let camerViewController = self.storyboard?.instantiateViewController(withIdentifier: Constant.camerViewController) as? CameraViewController{
            camerViewController.modalPresentationStyle = .fullScreen
//            camerViewController.delegate = self
            self.present(camerViewController, animated: true, completion: nil)
        }
        
        
    }
}
