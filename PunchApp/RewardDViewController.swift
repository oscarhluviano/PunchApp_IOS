//
//  RewardDViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 11/07/22.
//

import UIKit

class RewardDViewController: UIViewController {
    
    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtBenefit: UILabel!
    @IBOutlet weak var txtCost: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    
    var datos = Reward(id: "", title: "", benefit: "", cost: "", description: "", photo: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtTitle.text = datos.title
        txtBenefit.text = datos.benefit
        txtCost.text = "Cost: " + datos.cost
        txtDescription.text = datos.description
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
