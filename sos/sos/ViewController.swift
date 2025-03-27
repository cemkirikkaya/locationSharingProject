//
//  ViewController.swift
//  sos
//
//  Created by Cem Kırıkkaya on 15.12.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {
    
    
    @IBOutlet weak var Email: UITextField!
    
    @IBOutlet weak var Sifre: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signInClicked(_ sender: Any) {
        if Email.text != "" && Sifre.text != "" {
            Auth.auth().signIn(withEmail: Email.text!, password: Sifre.text!) {
                (result, error) in if error != nil {
                    self.makeAlert(title: "Hata", message: error!.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "goToHome", sender: nil)
                }
            }
        } else {
            makeAlert(title: "Hata", message: "Kullanıcı adı ve şifre hatalı")
        }
    }
    
    @IBAction func singUpClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toRegisterView", sender: nil)
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Tamam", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

