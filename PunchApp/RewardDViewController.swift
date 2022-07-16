//
//  RewardDViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 11/07/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class RewardDViewController: UIViewController {
    
    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtBenefit: UILabel!
    @IBOutlet weak var txtCost: UILabel!
    @IBOutlet weak var txtDescription: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var btnStatusEdit: UIButton!
    @IBOutlet weak var btnStatusDelete: UIButton!
    
    var datos = Reward(id: "", title: "", benefit: "", cost: "", description: "", photo: "")
    
    
    @IBAction func btnRedeem(_ sender: Any) {
        
        NetworkManager.isUnreachable { _ in
            self.performSegue(withIdentifier: "goHome", sender: nil)
        }
        
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let docRef = db.collection("users").document(userID)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let result = Int(document.get("points") as! String)! - Int(self.datos.cost)!
                if(result >= 0){
                    
                    docRef.updateData([
                        "points": String(result)
                        
                    ]) {
                        err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else
                        {
                            print("Document successfully updated")
                            db.collection("users").document(userID).collection("history").document().setData([
                                "id": self.datos.id,
                                "title": self.datos.title,
                                "benefit": self.datos.benefit,
                                "cost": self.datos.cost,
                                "description": self.datos.description,
                                "photo": self.datos.photo,
                                "redeemDate": FieldValue.serverTimestamp()
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(self.datos.id)")

                                    let alert = UIAlertController(title: "Congratulations", message: "Reward successfully redeemed", preferredStyle: .alert)
                                    let ac1 = UIAlertAction(title: "OK", style: .default, handler: { action in
                                        self.performSegue(withIdentifier: "goHome", sender: nil)
                                    })
                                    alert.addAction(ac1)
                                    self.present(alert, animated: true)
                                }
                            }
                        }
                    }
                }else{
                    let alert = UIAlertController(title: "Error", message: "Insufficient Balance", preferredStyle: .alert)
                    let ac1 = UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.performSegue(withIdentifier: "goHome", sender: nil)
                    })
                    alert.addAction(ac1)
                    self.present(alert, animated: true)
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    @IBAction func btnEditReward(_ sender: Any) {
        self.performSegue(withIdentifier: "editReward", sender: self)
    }
    
    @IBAction func btnDeleteReward(_ sender: Any) {
        NetworkManager.isUnreachable { _ in
            self.performSegue(withIdentifier: "goHome", sender: nil)
        }
        
        let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to delete this reward?", preferredStyle: .alert)
        let db = Firestore.firestore()
        let ac1 = UIAlertAction(title: "Confirm", style: .destructive, handler: { action in
            db.collection("rewards").document(self.datos.id).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    let alert = UIAlertController(title: "Great!", message: "Reward successfully deleted", preferredStyle: .alert)
                    let ac1 = UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.performSegue(withIdentifier: "goHome", sender: nil)
                    })
                    alert.addAction(ac1)
                    self.present(alert, animated: true)
                }
            }
        })
        let ac2 = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(ac1)
        alert.addAction(ac2)
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtTitle.text = datos.title
        txtBenefit.text = datos.benefit
        txtCost.text = "Cost: " + datos.cost
        txtDescription.text = datos.description
        imgView.image = UIImage(named: datos.photo)
        
        NetworkManager.isUnreachable { _ in
            self.performSegue(withIdentifier: "goHome", sender: nil)
        }
        
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let docRef = db.collection("users").document(userID)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let userType = (document.get("type") as! String)
                if(userType == "0"){
                    self.btnStatusEdit.isHidden = false
                    self.btnStatusDelete.isHidden = false
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if(segue.identifier == "editReward"){
            let nuevoVC = segue.destination as! EditRewardViewController
            // Pass the selected object to the new view controller.
            nuevoVC.reward = datos
        }
        
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
