//
//  ListeObjtViewController.swift
//  PJS4
//
//  Created by Aroun rdj on 29/03/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ListeObjetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    var tmpNomEvent: String!
    var tmpOwnerUID: String!
    var objets = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadObjets()
    }
    
    @IBAction func addBtn(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            ref.child("events").child(self.tmpOwnerUID!).child(self.tmpNomEvent!).child("objets").observeSingleEvent(of: .value) { (snapshot) in
                let indice = "objet" + String(snapshot.children.allObjects.count)
                ref.child("events").child(self.tmpOwnerUID!).child(self.tmpNomEvent!).child("objets").updateChildValues([indice: self.textField.text!])
                self.objets += [self.textField.text!]
                self.tableView.reloadData()
            }
        }
    }

    func loadObjets() {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            ref.child("events").child(tmpOwnerUID!).child(tmpNomEvent).child("objets").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.children.allObjects.count <= 0 {
                    return
                }
                for i in 0...snapshot.children.allObjects.count - 1 {
                    let objetsDic = snapshot.value as? NSDictionary
                    let currentObj = objetsDic!["objet" + String(i)] as! String // car dans firebase, la key est 0,1,2...
                    self.objets += [currentObj]
                }
                self.tableView.reloadData()
                self.showEmptyTableViewLabel()
            }
        }
    }
    
    func showEmptyTableViewLabel() {
        if tableView.visibleCells.isEmpty {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text = "Soyez la première personne à ramener quelque chose !"
            emptyLabel.font = emptyLabel.font.withSize(20)
            emptyLabel.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            emptyLabel.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = emptyLabel
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = objets[indexPath.row]
        cell.textLabel?.font = cell.textLabel?.font.withSize(20)
        return cell
    }

}
