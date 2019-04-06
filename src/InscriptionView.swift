//
//  InscriptionView.swift
//  PJS4
//
//  Created by Tristan Bilot on 22/01/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKCoreKit
import FBSDKLoginKit

class InscriptionView: UIViewController {

    @IBOutlet weak var nomField: UITextField!
    @IBOutlet weak var prenomField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var btnInscription: BasicButton!
    
    @IBAction func inscriptionPress(_ sender: Any) {
        
        if nomField.text == "" {
            print("Erreur de nom❗️")
            self.nomField.text = ""
            self.nomField.attributedPlaceholder = NSAttributedString(string:"Rentrez votre nom !", attributes:[NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1864722073, green: 0.8306357861, blue: 0.7382133603, alpha: 1), NSAttributedString.Key.font :UIFont(name: "Arial", size: 17)!])
        }
            else if prenomField.text == "" {
                print("Erreur de prénom❗️")
                self.prenomField.text = ""
                self.prenomField.attributedPlaceholder = NSAttributedString(string:"Rentrez votre prénom !", attributes:[NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1864722073, green: 0.8306357861, blue: 0.7382133603, alpha: 1), NSAttributedString.Key.font :UIFont(name: "Arial", size: 17)!])
            }
            else if !isValidEmail(testStr: mailField.text!) {
                print("Erreur de mail❗️")
                self.mailField.text = ""
                self.mailField.attributedPlaceholder = NSAttributedString(string:"Votre e-mail est incorrect !", attributes:[NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1864722073, green: 0.8306357861, blue: 0.7382133603, alpha: 1), NSAttributedString.Key.font :UIFont(name: "Arial", size: 17)!])
            }
            else if phoneField.text!.count != 10 {
                print("Erreur de numéro❗️")
                self.phoneField.text = ""
                self.phoneField.attributedPlaceholder = NSAttributedString(string:"Votre numéro est incorrect !", attributes:[NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1864722073, green: 0.8306357861, blue: 0.7382133603, alpha: 1), NSAttributedString.Key.font :UIFont(name: "Arial", size: 17)!])
            }
            else if passwordField.text!.count < 6 {
                print("Erreur de mot de passe❗️")
                self.passwordField.text = ""
                self.passwordField.attributedPlaceholder = NSAttributedString(string:"6 caractères minimum !", attributes:[NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1864722073, green: 0.8306357861, blue: 0.7382133603, alpha: 1), NSAttributedString.Key.font :UIFont(name: "Arial", size: 17)!])
            }
            else if confirmField.text != passwordField.text {
                print("Mots de passe non-identiques❗️")
                self.confirmField.text = ""
                self.confirmField.attributedPlaceholder = NSAttributedString(string:"Mots de passe différents !", attributes:[NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1864722073, green: 0.8306357861, blue: 0.7382133603, alpha: 1), NSAttributedString.Key.font :UIFont(name: "Arial", size: 17)!])
            } else {
                    Auth.auth().createUser(withEmail: mailField.text!, password: passwordField.text!)
                    { (authResult, error) in
                        if error != nil {
                            
                        } else {
                            print("Le user a été inscrit ✅")
                            let ref = Database.database().reference()
                            let UserID = Auth.auth().currentUser?.uid
                            
                            ref.child("users").child(UserID!).setValue(["name": self.nomField.text!, "firstname": self.prenomField.text!, "mail": self.mailField.text!, "password": self.passwordField.text!, "phone": self.phoneField.text!])
                            
                            self.performSegue(withIdentifier: "goEventsFromInscription", sender: self)
                            print("Connexion OK ✅")
                        }
                    }
                }
            }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = StaticVariables.background
        
        /* Facebook */
        let signInButton = UIButton(type: .custom)
        signInButton.layer.backgroundColor = Colors.bleuFB.cgColor
        signInButton.frame = CGRect(x: 70, y: 510, width: 235, height: 38)
        signInButton.setTitle("Continuer avec Facebook", for: .normal)
        signInButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 17)!
        signInButton.layer.cornerRadius = 18
        
        // Handle clicks on the button
        signInButton.addTarget(self, action: #selector(InscriptionView.signInButtonClicked), for: .touchUpInside)
        
        // Add the button to the view
        view.addSubview(signInButton)
        
        signInButton.layer.shadowColor = Colors.bleuFB.cgColor
        signInButton.layer.shadowRadius = 4
        signInButton.layer.shadowOpacity = 0.5
        signInButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        btnInscription.layer.shadowColor = Colors.blueBtn.cgColor
        btnInscription.layer.shadowRadius = 4
        btnInscription.layer.shadowOpacity = 0.5
        btnInscription.layer.shadowOffset = CGSize(width: 0, height: 0)
        
    }
    
    @objc func signInButtonClicked() {
        let login = FBSDKLoginManager()
        login.logIn(withReadPermissions: ["email","public_profile"], from: self, handler: { result, error in
            if error != nil {
                print("Process error")
            } else {
                self.inscriptionWithFacebookData()
            }
        })
    }
    
    func inscriptionWithFacebookData() {
        let accessToken = FBSDKAccessToken.current()
        if(accessToken != nil) //should be != nil
        {
            let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"], tokenString: accessToken!.tokenString, version: nil, httpMethod: "GET")
            req!.start(completionHandler: { (connection, result, error : Error!) -> Void in
                if(error == nil)
                {
                    print(result!)
                    let r = result as! Dictionary<String, String>
                    Auth.auth().createUser(withEmail: r["email"]!, password: r["id"]!)
                    { (authResult, error) in
                        if error != nil {
                            print(error as Any)
                        } else {
                            print("Le user a été inscrit avec Facebook ✅")
                            let ref = Database.database().reference()
                            let UserID = Auth.auth().currentUser?.uid
                            print(UserID!)
                            
                            ref.child("users").child(UserID!).setValue(["name": r["last_name"]!, "firstname": r["first_name"]!, "mail": r["email"]!, "password": r["id"]!, "phone": "0612345678"])
                            
                            self.performSegue(withIdentifier: "goEventsFromInscription", sender: self)
                            print("Connexion OK avec Facebook ✅")
                        }
                    }
                }
                else { print(error) }
            })
        }
    }

    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // Ajout des barres horizontales sous chaque textField
    enum LINE_POSITION {
        case LINE_POSITION_TOP
        case LINE_POSITION_BOTTOM
    }
    
    func addLineToView(view : UIView, position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        view.addSubview(lineView)
        
        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
        
        switch position {
        case .LINE_POSITION_TOP:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        }
    }


}
