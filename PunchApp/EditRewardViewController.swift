//
//  EditRewardViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 15/07/22.
//

import UIKit
import FirebaseFirestore

class EditRewardViewController: UIViewController {
    
    
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtBenefit: UITextField!
    @IBOutlet weak var txtCost: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    
    var reward = Reward(id: "", title: "", benefit: "", cost: "", description: "", photo: "")
    
    @IBAction func btnEditReward(_ sender: Any) {
        NetworkManager.isUnreachable { _ in
            self.performSegue(withIdentifier: "goHome", sender: nil)
        }

        let db = Firestore.firestore()
        
        if(txtTitle.text != "" && txtBenefit.text != "" && txtCost.text != "" && txtDescription.text != ""){
                if(isNumber(num: txtCost.text!)){
                    
                    let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to edit this reward?", preferredStyle: .alert)
                    let ac1 = UIAlertAction(title: "Confirm", style: .destructive, handler: { action in
                        let ref = db.collection("rewards").document(self.reward.id)
                        let docID = ref.documentID

                        ref.updateData([
                            "id": docID,
                            "title": self.txtTitle.text!,
                            "benefit": self.txtBenefit.text!,
                            "cost": self.txtCost.text!,
                            "description": self.txtDescription.text!,
                            "photo": "alferro.jpg"
                        ]) { err in
                            if let err = err {
                                print("Error adding document: \(err)")
                            } else {
                                print("Document added with ID: \(docID)")
                                let alert = UIAlertController(title: "Congratulations", message: "Reward successfully edited", preferredStyle: .alert)
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
    
    @IBAction func btnCancel(_ sender: Any) {
        self.performSegue(withIdentifier: "goHome", sender: nil)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func setupKeyboardHiding(){
        NotificationCenter.default.addObserver(self, selector: #selector(EditRewardViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditRewardViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification){
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentFirst() as? UITextField else { return }
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        if textFieldBottomY > keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY/2) * -1
            view.frame.origin.y = newFrameY
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        setupKeyboardHiding()
        
        txtTitle.text = reward.title
        txtBenefit.text = reward.benefit
        txtCost.text = reward.cost
        txtDescription.text = reward.description
        
    }
}

extension UIResponder{
    private struct Static{
        static weak var responder: UIResponder?
    }
    
    static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }
    
    @objc private func _trap(){
        Static.responder = self
    }
}

