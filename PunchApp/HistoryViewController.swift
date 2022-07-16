//
//  HistoryViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 09/07/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDate: UILabel!
}

class HistoryViewController:   UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnAddReward: UIButton!
    @IBOutlet weak var btnAddCoupon: UIButton!
    
    @IBOutlet weak var txtPoints: UITextField!
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var rewards = [History]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryTableViewCell
        let reward = rewards[indexPath.row]
        
        cell.txtTitle.text = reward.title
        cell.txtDate.text = "Redeem date: " + reward.redeemDate
        cell.imgView.image = UIImage(named: reward.photo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "details", sender: self)
    }
    
    func retreiveRewards(){
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).collection("history").order(by: "redeemDate", descending: true).getDocuments() { (QuerySnapshot, err) in
            if let err = err {
                print("Error getting documents : \(err)")
            }
            else {
                for document in QuerySnapshot!.documents{
                    let timestamp: Timestamp = document.get("redeemDate") as! Timestamp
                    let date: Date = timestamp.dateValue()
                    let dateFormatter = DateFormatter()
//                    dateFormatter.dateFormat = "d, MMM YY, HH:mm:ss"
                    dateFormatter.dateStyle = .full
                    dateFormatter.timeStyle = .full
                    
                    if(document.documentID != "empty"){
                        let reward = History(id: document.documentID,
                                            title: document.get("title") as! String,
                                            benefit: document.get("benefit") as! String,
                                            cost: document.get("cost") as! String,
                                            description: document.get("description") as! String,
                                            photo: document.get("photo") as! String,
                                            redeemDate: dateFormatter.string(from: date))
                        self.rewards.append(reward)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
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
        
        retreiveRewards()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if(segue.identifier == "details"){
            let nuevoVC = segue.destination as! HistoryDViewController
            // Pass the selected object to the new view controller.
            if let indexPath = tableView.indexPathForSelectedRow {
                let dataDic = rewards[indexPath.row]
                nuevoVC.datos = dataDic
                tableView.deselectRow(at: indexPath, animated: true)
            }
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
