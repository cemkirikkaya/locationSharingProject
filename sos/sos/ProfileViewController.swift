//
//  ProfileViewController.swift
//  sos
//
//  Created by Cem Kırıkkaya on 15.12.2024.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logOutClicked(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "goToBase", sender: nil)
        } catch {
            print("Hata")
        }
    }
}
