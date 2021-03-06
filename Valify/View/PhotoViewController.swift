
import UIKit

public protocol ValifyImageDelegate {
    func retriveImage(image:UIImage)
    
}

public class PhotoViewController: UIViewController {
    
    @IBOutlet weak var userImgaeView: UIImageView?
    var image:UIImage?
    public override func viewDidLoad() {
        super.viewDidLoad()
        userImgaeView?.image = image
    }
    @IBAction func retakePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func approvePressed(_ sender: Any) {
        ValifyInit.shared.delegate?.retriveImage(image: image ?? UIImage())
        let root = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        root?.dismiss(animated: true, completion: nil)

    }

}
