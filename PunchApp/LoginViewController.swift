//
//  LoginViewController.swift
//  PunchApp
//
//  Created by Oscar Hernandez on 07/07/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPswd: UITextField!
    
    @IBAction func btnLogin(_ sender: Any) {
        
//        Auth.auth().signIn(withEmail: self.txtEmail.text!, password: self.txtPswd.text!) { (user, error) in
//            if error != nil {
//                let alert = UIAlertController(title: "", message: "Ocurrió un error \(error!.localizedDescription)", preferredStyle: UIAlertController.Style.alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
////                DispatchQueue.main.async {
////                    self.a_i.stopAnimating()
////                    self.present(alert, animated: true, completion: nil)
////                }
//                print("error")
//            }
//            else {
//                print("exito")
////                DispatchQueue.main.async {
////                    self.a_i.stopAnimating()
//                    self.performSegue(withIdentifier: "goHome", sender: nil)
////                }
//            }
//        }
        self.performSegue(withIdentifier: "goHome", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
