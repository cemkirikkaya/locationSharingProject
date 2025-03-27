//
//  RegisterViewController.swift
//  sos
//
//  Created by Cem Kırıkkaya on 15.12.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var Email: UITextField!
    
    @IBOutlet weak var Sifre: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func buttonClicked(_ sender: Any) {
        if Email.text != "" && Sifre.text != "" {
            Auth.auth().createUser(withEmail: Email.text!, password: Sifre.text!) {
                authResult, error in
                if error != nil {
                    self.makeAlert(title: "Hata", message: error!.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "goToHome", sender: nil)
                }
            }
            var firestoreReferans : DocumentReference? = nil
            let firestoreAdd = ["mail": Email.text!, "sifre": Sifre.text!]
            firestoreReferans = db.collection("Users").addDocument(data: firestoreAdd)
        } else {
            makeAlert(title: "Hata", message: "Lütfen email ve şifre alanları boş bırakmayınız")
        }
    }
    
    func makeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Tamam", style: .default)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

