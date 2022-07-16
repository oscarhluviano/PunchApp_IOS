//
//  RedeemViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 09/07/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class RedeemViewController: UIViewController, UITabBarControllerDelegate {
    
    @IBOutlet weak var btnAddReward: UIButton!
    @IBOutlet weak var btnAddCoupon: UIButton!
    
    @IBOutlet weak var txtPoints: UITextField!
    
    @IBOutlet weak var txtRedeemCoupon: UITextField!
    
    
    @IBAction func btnRedeem(_ sender: Any) {
        NetworkManager.isUnreachable { _ in
            return
        }

        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let userRef = db.collection("users").document(userID)
        
        if(txtRedeemCoupon.text != ""){
            let couponRef = db.collection("coupons").document(txtRedeemCoupon.text!)
            couponRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let status = (document.get("status") as! String)
                    if(status == "1"){
                        let couponPoints = Int(document.get("points") as! String)!
                        userRef.getDocument { (doc, err) in
                            if let doc = doc, doc.exists {
                                let points = Int(doc.get("points") as! String)! + couponPoints
                                print(points)
                                userRef.updateData([
                                    "points": String(points)
                                ]) { err in
                                    if let err = err {
                                        print("Error updating document: \(err)")
                                    } else {
                                        print("Document successfully updated")
                                            couponRef.updateData([
                                                "status": "0"
                                            ]) { err in
                                                if let err = err {
                                                    print("Error updating document: \(err)")
                                                } else {
                                                    print("Document successfully updated")
                                                    print("Document does not exist")
                                                    let alert = UIAlertController(title: "Congratulations", message: "Coupon successfully redeemed", preferredStyle: .alert)
                                                    let ac1 = UIAlertAction(title: "OK", style: .default)
                                                    alert.addAction(ac1)
                                                    self.present(alert, animated: true)
                                                    self.txtPoints.text = String(points)
                                                    self.txtRedeemCoupon.text = ""
                                                }
                                            }
                                    }
                                }
                            } else {
                                print("Document does not exist")
                            }
                        }
                    }else{
                        print("Document does not exist")
                        let alert = UIAlertController(title: "Error", message: "Coupon has been already redeemed", preferredStyle: .alert)
                        let ac1 = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(ac1)
                        self.present(alert, animated: true)
                    }
                }else{
                    let alert = UIAlertController(title: "Error", message: "Coupon doesn't exist", preferredStyle: .alert)
                    let ac1 = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ac1)
                    self.present(alert, animated: true)
                }
            }
        }else{
            let alert = UIAlertController(title: "Error", message: "Empty field", preferredStyle: .alert)
            let ac1 = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ac1)
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtPoints.isUserInteractionEnabled = false

        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let docRef = db.collection("users").document(userID)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let userType = (document.get("type") as! String)
                if(userType == "0"){
                    self.btnAddReward.isHidden = false
                    self.btnAddCoupon.isHidden = false
                }
                self.txtPoints.text = (document.get("points") as! String)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NetworkManager.isUnreachable { _ in
            let alert = UIAlertController(title: "Error", message: "No internet", preferredStyle: .alert)
            let ac1 = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ac1)
            self.present(alert, animated: true)
            self.view.isUserInteractionEnabled = false
        }
        
        NetworkManager.isReachable { _ in
            self.view.isUserInteractionEnabled = true
        }

        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let docRef = db.collection("users").document(userID)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.txtPoints.text = (document.get("points") as! String)
            } else {
                print("Document does not exist")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NetworkManager.isReachable { _ in
            self.view.isUserInteractionEnabled = true
        }
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

}
