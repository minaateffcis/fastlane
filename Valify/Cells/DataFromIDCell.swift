//
//  DataFromIDCell.swift
//  Valify
//
//  Created by Mina Atef on 20/10/2021.
//

import UIKit

class DataFromIDCell: UITableViewCell {
    
    
    @IBOutlet weak var lable1: UILabel!
    @IBOutlet weak var lable2: UILabel!
    @IBOutlet weak var lable5: UILabel!
    @IBOutlet weak var lable6: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    @IBOutlet weak var nidImage: UIImageView!
    @IBOutlet weak var label6Value: UILabel!
    @IBOutlet weak var label5Value: UILabel!
    @IBOutlet weak var label4Value: UILabel!
    @IBOutlet weak var label3Value: UILabel!
    @IBOutlet weak var label2Vlue: UILabel!
    @IBOutlet weak var label1Value: UILabel!
    func setValues(userData:UserModel){
        switch ValifyInit.shared.watermarkType {
        case .frontCapture:
            lable1.text = "First Name"
            lable2.text = "Score"
            label3.text = "Area"
            label4.text = "Street"
            lable5.text = "Front NID"
            lable6.text = "Serial Number"
            label1Value.text = "\( userData.firstName ?? "") \(userData.fullName ?? "")"
            label2Vlue.text = "\(userData.watermarkResponse?.score ?? "") \n \(userData.watermarkPlace ?? "")"
            label3Value.text = userData.area
            label4Value.text = userData.street
            label5Value.text = userData.frontNid
            label6Value.text = userData.serialNumber
            nidImage.image = userData.scannedImage
        case .backCapture:
            lable1.text = "Back NID"
            lable2.text = "Expiry Date"
            label3.text = "Release Date"
            label4.text = "Gender"
            lable5.text = "Profession"
            lable6.text = "Religion"
            label1Value.text = userData.backNid
            label2Vlue.text = userData.expiryDate
            label3Value.text = userData.releaseDate
            label4Value.text = userData.gender
            label5Value.text = userData.profession
            label6Value.text = userData.religion
            nidImage.image = userData.scannedImage
        case .none:
            break
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
