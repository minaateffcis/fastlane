//

//  Valify
//
//  Created by Mina Atef on 19/08/2021.
//

import Foundation
import UIKit

public class ValifyInit{
    private init(){}
    public static var shared = ValifyInit()
    public var delegate : ValifyImageDelegate?
    public var presentingViewController : UIViewController?
    
    public func start()  {
        let storyboard = UIStoryboard.init(name: Constant.storyboardName, bundle: Bundle(for: CameraViewController.self))
        let homeVC = storyboard.instantiateViewController(withIdentifier: Constant.camerViewController)
        presentingViewController?.present(homeVC, animated: true, completion: nil)
    }
}
