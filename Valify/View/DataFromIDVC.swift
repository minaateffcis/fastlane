//
//  DataFromIDVC.swift
//  Valify
//
//  Created by Mina Atef on 20/10/2021.
//

import UIKit
import RxSwift
import RxCocoa

class DataFromIDVC: UIViewController {

    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var cardDataTableView: UITableView!
    var disposeBag = DisposeBag()
    var cardData = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeOnScanedData()
        observeOnError()
        loadingView.isHidden = false
        loadingLabel.isHidden = false
//        Hud.showLoading()
    }
    
    func observeOnScanedData(){
        OCRData.OCRDataArr.asObservable().subscribe(onNext: { [unowned self] (data) in
            for errorMessage in OCRData.errorMessages{
                Alert.show(message: errorMessage)
            }
            loadingView.isHidden = true
            loadingLabel.isHidden = true
            cardData.append(data)
            cardDataTableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    func observeOnError(){
        OCRData.error.asObservable().subscribe(onNext: { [unowned self] (error) in
            loadingView.isHidden = true
            loadingLabel.isHidden = true
        }).disposed(by: disposeBag)
    }
    
    
    @IBAction func rescanPressed(_ sender: Any) {
        let root = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController
        root?.dismiss(animated: true, completion: nil)
    }
    


}
extension DataFromIDVC:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cardDataTableView.dequeueReusableCell(withIdentifier: "DataFromIDCell", for: indexPath) as! DataFromIDCell
        cell.setValues(userData:cardData[indexPath.row])
        return cell
    }
    
}
