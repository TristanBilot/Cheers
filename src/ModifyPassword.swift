//
//  ModifyPassword.swift
//  PJS4
//
//  Created by Tristan Bilot on 29/01/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ModifyPassword: UIViewController {

    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword1: UITextField!
    @IBOutlet weak var newPassword2: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func modifyPassword(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            let userUID = Auth.auth().currentUser?.uid
            ref.child("users").child(userUID!).observeSingleEvent(of: .value) { (snapchot) in
                
                let value = snapchot.value as? NSDictionary
                let mail = value?["mail"] as? String ?? ""
                let firstname = value?["firstname"] as? String ?? ""
                let name = value?["name"] as? String ?? ""
                let phone = value?["phone"] as? String ?? ""
                
                if self.newPassword1.text! == self.newPassword2.text! {
                    if self.newPassword2.text! != self.oldPassword.text! {
                        ref.child("users").child(userUID!).setValue(["name": name, "firstname": firstname, "mail": mail, "password": self.newPassword1.text!, "phone": phone])
                        self.errorLabel.isHidden = false
                        self.errorLabel.textColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1)
                        self.errorLabel.text = "Votre mot de passe a bien été modifié !"
                    }
                    else {
                        print("Erreur de password: l'ancien mdp = le nouveau mdp ❗️")
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = "Les deux mots de passe sont les mêmes"
                    }
                }
                else {
                    print("Erreur de password: les 2 mdp sont différents ❗️")
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = "Les deux mots de passe sont différents"
                }
                
            }
        }
    }
    

}
