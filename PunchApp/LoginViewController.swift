//
//  LoginViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 07/07/22.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPswd: UITextField!
    
    
    @IBAction func btnLogin(_ sender: Any) {
        
        NetworkManager.isUnreachable { _ in
            let alert = UIAlertController(title: "Error", message: "No internet", preferredStyle: .alert)
            let ac1 = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ac1)
            self.present(alert, animated: true)
            return
        }
        
        if(txtEmail.text != "" && txtPswd.text != ""){
            Auth.auth().signIn(withEmail: self.txtEmail.text!, password: self.txtPswd.text!) { (user, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: "Invalid email or password", preferredStyle: .alert)
                    let ac1 = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(ac1)
                    self.present(alert, animated: true)
                    print("error")
                }
                else {
                    print("exito")
    //                DispatchQueue.main.async {
    //                    self.a_i.stopAnimating()
                        self.performSegue(withIdentifier: "goHome", sender: nil)
    //                }
                }
            }
        }else{
            let alert = UIAlertController(title: "Error", message: "Don't leave empty fields", preferredStyle: .alert)
            let ac1 = UIAlertAction(title: "OK", style: .default)
            alert.addAction(ac1)
            self.present(alert, animated: true)
        }
    }
    
    
    @IBAction func btnLoginGoogle(_ sender: Any) {
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
                            self.performSegue(withIdentifier: "goHome", sender: nil)
                        } else {
                            print("Document does not exist")
                            let firebaseAuth = Auth.auth()
                            do {
                              try firebaseAuth.signOut()
                            } catch let signOutError as NSError {
                              print("Error signing out: %@", signOutError)
                            }
                            let alert = UIAlertController(title: "Congratulations", message: "Reward successfully redeemed", preferredStyle: .alert)
                            let ac1 = UIAlertAction(title: "OK", style: .default, handler: { action in
                            })
                            alert.addAction(ac1)
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
    
    private func setupKeyboardHiding(){
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        setupKeyboardHiding()
        
    }
    
    
}
