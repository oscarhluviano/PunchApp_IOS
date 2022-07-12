//
//  RewardsViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 09/07/22.
//

import UIKit
import FirebaseFirestore

class RewardsViewController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var btnAddReward: UIButton!
    @IBOutlet weak var btnAddCoupon: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var rewards = [Reward]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let reward = rewards[indexPath.row]
        
        cell.textLabel?.text = reward.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detailsReward", sender: self)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
                
        if(true){
            btnAddReward.isHidden = true
        }
        
        retreiveRewards()

        // Do any additional setup after loading the view.
    }
    
    func retreiveRewards(){
        let db = Firestore.firestore()
        
        db.collection("rewards").getDocuments() { (QuerySnapshot, err) in
                if let err = err {
                    print("Error getting documents : \(err)")
                }
                else {
                    for document in QuerySnapshot!.documents{
                        let reward = Reward(id: document.documentID,
                                            title: document.get("title") as! String,
                                            benefit: document.get("benefit") as! String,
                                            cost: document.get("cost") as! String,
                                            description: document.get("description") as! String,
                                            photo: document.get("photo") as! String)
                        self.rewards.append(reward)
                        self.tableView.reloadData()
                    }
                    
                }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        let nuevoVC = segue.destination as! RewardDViewController
        // Pass the selected object to the new view controller.
        if let indexPath = tableView.indexPathForSelectedRow {
            let dataDic = rewards[indexPath.row]
            nuevoVC.datos = dataDic
            tableView.deselectRow(at: indexPath, animated: true)
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
