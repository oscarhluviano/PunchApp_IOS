//
//  AddRewardViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 12/07/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddRewardViewController: UIViewController {
    
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtBenefit: UITextField!
    @IBOutlet weak var txtCost: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    
    
    @IBAction func btnAddReward(_ sender: Any) {
        
        NetworkManager.isUnreachable { _ in
            self.performSegue(withIdentifier: "goHome", sender: nil)
        }
        
        let db = Firestore.firestore()
        
        if(txtTitle.text != "" && txtBenefit.text != "" && txtCost.text != "" && txtDescription.text != ""){
                if(isNumber(num: txtCost.text!)){
                    let ref = db.collection("rewards").document()
                    let docID = ref.documentID

                    ref.setData([
                        "id": docID,
                        "title": txtTitle.text!,
                        "benefit": txtBenefit.text!,
                        "cost": txtCost.text!,
                        "description": txtDescription.text!,
                        "photo": "alferro.jpg"
                    ]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: \(docID)")
                            let alert = UIAlertController(title: "Congratulations", message: "Reward successfully added", preferredStyle: .alert)
                            let ac1 = UIAlertAction(title: "OK", style: .default, handler: { action in
                                self.performSegue(withIdentifier: "goHome", sender: nil)
                            })
                            alert.addAction(ac1)
                            self.present(alert, animated: true)
                        }
                    }
                }else{
                    let alert = UIAlertController(title: "Error", message: "Wrong Cost format", preferredStyle: .alert)
                    let ac1 = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ac1)
                    self.present(alert, animated: true)
                }
        }else{
            let alert = UIAlertController(title: "Error", message: "Don't leave empty fields", preferredStyle: .alert)
            let ac1 = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ac1)
            self.present(alert, animated: true)
        }
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func isNumber(num: String)-> Bool{
        let num = Int(num)
        if num != nil {
         print("Valid Integer")
            return true
        }
        else {
         print("Not Valid Integer")
            return false
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
