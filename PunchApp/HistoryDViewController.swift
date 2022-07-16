//
//  HistoryDViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 14/07/22.
//

import UIKit

class HistoryDViewController: UIViewController {
    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtBenefit: UILabel!
    @IBOutlet weak var txtCost: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    @IBOutlet weak var txtRedeemDate: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    var datos = History(id: "", title: "", benefit: "", cost: "", description: "", photo: "", redeemDate: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtTitle.text = datos.title
        txtBenefit.text = datos.benefit
        txtCost.text = "Cost: " + datos.cost
        txtDescription.text = datos.description
        txtRedeemDate.text = "Redeem date: " + datos.redeemDate
        imgView.image = UIImage(named:datos.photo)
        
    }
    

}
