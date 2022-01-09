//

//  Valify
//
//  Created by Mina Atef on 19/08/2021.
//

import Foundation
import UIKit
//import Sentry
public enum WatermarkType {
    case backCapture
    case frontCapture
}

public class ValifyInit{
    
    
    private init() {
        Constant.serverType(server: .Dev)
        UIApplication.shared.isIdleTimerDisabled = true
//      UserDefaults.standard.set(true, forKey: "crash")
      NotificationCenter.default.addObserver(self,
          selector: #selector(applicationWillTerminate(notification:)),
          name: UIApplication.willTerminateNotification,
          object: nil)
    }

    @objc func applicationWillTerminate(notification: Notification) {
      // Notification received.
        UserDefaults.standard.set(false, forKey: "crash")
        let c = UserDefaults.standard.bool(forKey: "crash")
        
        
    }

    deinit {
      NotificationCenter.default.removeObserver(self)
    }
    

    public static var shared = ValifyInit()
    public var delegate : ValifyImageDelegate?
    public var presentingViewController : UIViewController?
    public var numberOfImages:Int?
    public var upwardSpeed:Int?
    public var downwardSpeed:Int?
    public var watermarkType:WatermarkType?
    
    public func start()  {
//        Logger.shared.debugPrint("test")
        
        let storyboard = UIStoryboard.init(name: Constant.storyboardName, bundle: Bundle(for: StartVC.self))
        let homeVC = storyboard.instantiateViewController(withIdentifier: Constant.startVC)
        homeVC.modalPresentationStyle = .fullScreen
        presentingViewController?.present(homeVC, animated: true, completion: nil)
    }
}


class Logger {
    static let shared = Logger()
    private init(){}
    func debugPrint(
            _ message: Any,
            extra1: String = #file,
            extra2: String = #function,
            extra3: Int = #line,
            remoteLog: Bool = false,
            plain: Bool = false
        ) {
            if plain {
                print(message)
            }
            else {
                let filename = (extra1 as NSString).lastPathComponent
                print(message, "[\(filename) \(extra2) Function \(extra3) line]")
            }
            
            // if remoteLog is true record the log in server
            if remoteLog {
//                if let msg = message as? String {
//                    logEvent(msg, event: .error, param: nil)
//                }
            }
        }
}
