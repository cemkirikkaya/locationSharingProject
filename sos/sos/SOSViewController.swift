//
//  SOSViewController.swift
//  sos
//
//  Created by Cem Kırıkkaya on 16.12.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SOSViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var emails = [String]();
    let nesne = ChatViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        tableView.delegate = self
        tableView.dataSource = self
        mailList()
    }
    
    @objc func addButtonClicked() {
        performSegue(withIdentifier: "toShare", sender: nil)
    }
    
    func mailList() {
        let fireStore = Firestore.firestore()
        fireStore.collection("Users").addSnapshotListener { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if snapshot?.isEmpty != true {
                    for document in snapshot!.documents {
                        if Auth.auth().currentUser?.email == document.get("mail") as? String {} else {
                            if let mails = document.get("mail") as? String {
                                self.emails.append(mails)
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = emails[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toChat", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            emails.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

