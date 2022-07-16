//
//  SignUpViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 12/07/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseCore


class SignUpViewController: UIViewController {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPswd: UITextField!
    
    @IBAction func btnSignUp(_ sender: Any) {
        
        NetworkManager.isUnreachable { _ in
            let alert = UIAlertController(title: "Error", message: "No internet", preferredStyle: .alert)
            let ac1 = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ac1)
            self.present(alert, animated: true)
            return
        }
        
        let db = Firestore.firestore()
        
        
        if(txtName.text != "" && txtEmail.text != "" && txtPassword.text != "" && txtConfirmPswd.text != ""){
            if(txtPassword.text!.count >= 6){
                if(txtPassword.text == txtConfirmPswd.text){
                    Auth.auth().createUser(withEmail: txtEmail.text!, password: txtPassword.text!) { authResult, error in
                        if let error = error as? NSError {
                            print("Error: \(error.localizedDescription)")
                            switch error.code {
                            case AuthErrorCode.invalidEmail.rawValue:
                                print("invalid email")
                                let alert = UIAlertController(title: "Error", message: "Email address is badly formatted", preferredStyle: .alert)
                                let ac1 = UIAlertAction(title: "OK", style: .default)
                                alert.addAction(ac1)
                                self.present(alert, animated: true)
                            case AuthErrorCode.emailAlreadyInUse.rawValue:
                                print("email already in use")
                                let alert = UIAlertController(title: "Error", message: "Email already in use", preferredStyle: .alert)
                                let ac1 = UIAlertAction(title: "OK", style: .default)
                                alert.addAction(ac1)
                                self.present(alert, animated: true)
                            default:
                                print("unknown error: \(error.localizedDescription)")
                            }
                            return
                        } else {
                            print("User signs up successfully")
                            guard let userID = Auth.auth().currentUser?.uid else { return }
                            db.collection("users").document(userID).setData([
                                "email": self.txtEmail.text!,
                                "name": self.txtName.text!,
                                "points": "0",
                                "provider": "email",
                                "type": "1"
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(userID)")
                                    db.collection("users").document(userID).collection("history").document("empty").setData([
                                        "id": "empty",
                                        "title": "empty",
                                        "benefit": "empty",
                                        "cost": "empty",
                                        "description": "empty",
                                        "photo": "empty",
                                        "redeemDate": FieldValue.serverTimestamp()
                                    ]) { err in
                                        if let err = err {
                                            print("Error adding document: \(err)")
                                        } else {
                                            print("Document added with ID: empty")
                                            self.performSegue(withIdentifier: "goLogin", sender: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else{
                    let alert = UIAlertController(title: "Error", message: "Passwords doesn't match", preferredStyle: .alert)
                    let ac1 = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ac1)
                    self.present(alert, animated: true)
                }
            }else{
                let alert = UIAlertController(title: "Error", message: "Password must have 6 or more characters", preferredStyle: .alert)
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
    
    
    @IBAction func btnSignUpGoogle(_ sender: Any) {
        NetworkManager.isUnreachable { _ in
            let alert = UIAlertController(title: "Error", message: "No internet", preferredStyle: .alert)
            let ac1 = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ac1)
            self.present(alert, animated: true)
            return
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            
            if error != nil {
                print("Error: \(error!.localizedDescription)")
                return
            }
            guard let authentication = user?.authentication, let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error as? NSError {
                    print("Error: \(error.localizedDescription)")
                    return
                } else {
                    print("User signs up successfully")
                    
                    guard let userID = Auth.auth().currentUser?.uid else { return }
                    let db = Firestore.firestore()
                    
                    let ref = db.collection("users").document(userID)
                    ref.getDocument { (document, error) in
                        if let document = document, document.exists {
                            self.performSegue(withIdentifier: "goLogin", sender: nil)
                        } else {
                            print("Document does not exist")
                            ref.setData([
                                "email": user?.profile?.email as Any,
                                "name": user?.profile?.name as Any,
                                "points": "0",
                                "provider": "google",
                                "type": "1"
                            ]) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added with ID: \(userID)")
                                    db.collection("users").document(userID).collection("history").document("empty").setData([
                                        "id": "empty",
                                        "title": "empty",
                                        "benefit": "empty",
                                        "cost": "empty",
                                        "description": "empty",
                                        "photo": "empty",
                                        "redeemDate": FieldValue.serverTimestamp()
                                    ]) { err in
                                        if let err = err {
                                            print("Error adding document: \(err)")
                                        } else {
                                            print("Document added with ID: empty")
                                            self.performSegue(withIdentifier: "goLogin", sender: nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
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
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func setupKeyboardHiding(){
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        setupKeyboardHiding()
        // Do any additional setup after loading the view.
    }
}

//extension UIResponder{
//    private struct Static{
//        static weak var responder: UIResponder?
//    }
//    
//    static func currentFirst() -> UIResponder? {
//        Static.responder = nil
//        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
//        return Static.responder
//    }
//    
//    @objc private func _trap(){
//        Static.responder = self
//    }
//}
