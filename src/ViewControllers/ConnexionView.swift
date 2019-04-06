//
//  ConnexionView.swift
//  PJS4
//
//  Created by Tristan Bilot on 22/01/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth // pour l'authentification
import FBSDKLoginKit // login FB

class ConnexionView: UIViewController {

    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var btnConnexion: BasicButton!
    
    @IBAction func ConnexionPress(_ sender: Any) {
        Auth.auth().signIn(withEmail: mailField.text!, password: passwordField.text!) { (authResult, error) in
            if error != nil {
                self.mailField.text = ""
                self.mailField.attributedPlaceholder = NSAttributedString(string:"Identifiants incorrects !", attributes:[NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1864722073, green: 0.8306357861, blue: 0.7382133603, alpha: 1), NSAttributedString.Key.font :UIFont(name: "Arial", size: 17)!])
            } else {
                self.performSegue(withIdentifier: "goCompteFromEvents", sender: self)
                print("Connexion OK ✅")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        /* Facebook connexion */
//        self.errorLabel.isHidden = true
        
        /* Facebook */
        let loginButton = UIButton(type: .custom)
//        loginButton.setImage(UIImage(named: "user.png"), for: .normal)
        loginButton.layer.backgroundColor = Colors.bleuFB.cgColor
        loginButton.frame = CGRect(x: 70, y: 450, width: 235, height: 38)
        loginButton.setTitle("Continuer avec Facebook",for: .normal)
        loginButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 17)!
        loginButton.layer.cornerRadius = 18
        
        // Handle clicks on the button
        loginButton.addTarget(self, action: #selector(ConnexionView.loginButtonClicked), for: .touchUpInside)
        
        // Add the button to the view
        view.addSubview(loginButton)
        
        loginButton.layer.shadowColor = Colors.bleuFB.cgColor
        loginButton.layer.shadowRadius = 4
        loginButton.layer.shadowOpacity = 0.5
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        btnConnexion.layer.shadowColor = Colors.blueBtn.cgColor
        btnConnexion.layer.shadowRadius = 4
        btnConnexion.layer.shadowOpacity = 0.5
        btnConnexion.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
 
        @objc func loginButtonClicked() {
            let login = FBSDKLoginManager()
            login.logIn(withReadPermissions: ["email","public_profile"], from: self, handler: { result, error in
                if error != nil {
                    print("Process error")
                } else {
                    self.loginWithFacebookData()
                }
            })
        }
        
        func loginWithFacebookData() {
            let accessToken = FBSDKAccessToken.current()
            if(accessToken != nil) //should be != nil
            {
                let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email"], tokenString: accessToken!.tokenString, version: nil, httpMethod: "GET")
                req!.start(completionHandler: { (connection, result, error : Error!) -> Void in
                    if(error == nil)
                    {
                        print(result!)
                        let r = result as! Dictionary<String, String>
                        Auth.auth().signIn(withEmail: r["email"]!, password: r["id"]!) { (authResult, error) in
                            if error != nil {
                                self.errorLabel.isHidden = false
                                self.errorLabel.text = "Email ou mot de passe invalide !"
                            } else {
                                self.performSegue(withIdentifier: "goCompteFromEvents", sender: self)
                                print("Connexion OK ✅")
                            }
                        }
                    }
                    else { print(error) }
                })
            }
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
