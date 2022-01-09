//
//  PreviewCapturedImagesVC.swift
//  Valify
//
//  Created by Mina Atef on 30/09/2021.
//

import UIKit

class ImageSaver: NSObject {
    static func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
    }

//    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        print("Save finished!")
//    }
}

class PreviewCapturedImagesVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var imagesArray = [UIImage]()
    
    @IBOutlet weak var imagesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func saveImages(){
        for image in imagesArray{
            ImageSaver.writeToPhotoAlbum(image: image)
        }
        
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "previewImagesCell", for: indexPath) as! PreivewImagesCell
        cell.previewImageView.image = imagesArray[indexPath.row]
        return cell
    }
    
    @IBAction func saveImages(_ sender: Any) {
        saveImages()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
