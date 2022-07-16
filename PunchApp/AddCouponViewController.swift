//
//  AddCouponViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 12/07/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth


class AddCouponViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtPoints: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    var coupons = [Coupon]()
    
    @IBAction func btnAddCoupon(_ sender: Any) {
        NetworkManager.isUnreachable { _ in
            self.performSegue(withIdentifier: "goHome", sender: nil)
        }
        
        let db = Firestore.firestore()
        
        if(txtTitle.text != "" && txtPoints.text != ""){
                if(isNumber(num: txtPoints.text!)){
                    let ref = db.collection("coupons").document(txtTitle.text!)
                    let docID = ref.documentID
                    
                    ref.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let alert = UIAlertController(title: "Error", message: "This code already exists", preferredStyle: .alert)
                            let ac1 = UIAlertAction(title: "OK", style: .default)
                            alert.addAction(ac1)
                            self.present(alert, animated: true)
                        } else {
                            print("Document does not exist")
                            ref.setData([
                                "id": self.txtTitle.text!,
                                "points": self.txtPoints.text!,
                                "status": "1"
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(docID)")
                                    let alert = UIAlertController(title: "Congratulations", message: "Coupon successfully added", preferredStyle: .alert)
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
                    let alert = UIAlertController(title: "Error", message: "Wrong Points format", preferredStyle: .alert)
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "reuseIdentifier")
        }
        let coupon = coupons[indexPath.row]
        
        cell?.textLabel?.text = coupon.id
        cell?.detailTextLabel?.text = "Points: " + coupon.points
        
        if(coupon.status == "1"){
            cell?.textLabel?.textColor = .green
        }else{
            cell?.textLabel?.textColor = .red
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "details", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        retreiveCoupons()
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
    
    func retreiveCoupons(){
        let db = Firestore.firestore()
        
        db.collection("coupons").getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents : \(err)")
            }
            else {
                for document in QuerySnapshot!.documents{
                        let reward = Coupon(id: document.documentID,
                                            points: document.get("points") as! String,
                                            status: document.get("status") as! String)
                        self.coupons.append(reward)
                }
                self.tableView.reloadData()
            }
        }
    }

}
