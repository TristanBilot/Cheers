//
//  ModifyCompteView.swift
//  PJS4
//
//  Created by Tristan Bilot on 29/01/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
class ModifyCompteView: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    @IBOutlet weak var profilImage: UIImageView!
    @IBOutlet weak var prenomField: UITextField!
    @IBOutlet weak var nomField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var btnAjouter: UIButton!
    @IBOutlet weak var btnChangerPhoto: UIButton!
    
    
    
    var selectedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        applyImageStyle()
        initializeFields()
        profilImage.layer.zPosition = 2
        btnChangerPhoto.layer.cornerRadius = btnChangerPhoto.frame.height / 2
        loadImage()
    }
    
  
    
    private func initializeFields() {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            let userUID = Auth.auth().currentUser?.uid
            ref.child("users").child(userUID!).observeSingleEvent(of: .value) { (snapchot) in
                let value = snapchot.value as? NSDictionary
                let mail = value?["mail"] as? String ?? ""
                let firstname = value?["firstname"] as? String ?? ""
                let name = value?["name"] as? String ?? ""
                let phone = value?["phone"] as? String ?? ""
                self.prenomField.text = firstname
                self.nomField.text = name
                self.emailField.text = mail
                self.phoneField.text = String(phone)
                print(self.prenomField.text!)
            }
        }
    }
    
    func applyImageStyle() {
        self.profilImage.layer.cornerRadius = self.profilImage.frame.height / 2
        self.profilImage.clipsToBounds = true
        self.profilImage.layer.borderColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1).cgColor
        self.profilImage.layer.borderWidth = 4
    }
    
    @IBAction func modifierPress(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            let userUID = Auth.auth().currentUser?.uid
            ref.child("users").child(userUID!).observeSingleEvent(of: .value) { (snapchot) in
                
                let storage = Storage.storage()
                var data = Data()
                data = self.profilImage.image!.pngData()! // image file name
                let storageRef = storage.reference()
                let imageRef = storageRef.child("images/profil/" + userUID! + ".png")
                _ = imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
                    guard metadata != nil else{
                        print(error as Any)
                        return
                    }
                })
                
                let value = snapchot.value as? NSDictionary
                let password = value?["password"] as? String ?? ""
                
                
                if self.isValidEmail(testStr: self.emailField.text!) {
                    if self.phoneField.text!.count == 10 {
                        ref.child("users").child(userUID!).setValue(["name": self.nomField.text!, "firstname": self.prenomField.text!, "mail": self.emailField.text!, "password": password, "phone": self.phoneField.text!])
//                        self.errorLabel!.isHidden = false
//                        self.errorLabel!.textColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1)
//                        self.errorLabel!.text = "Votre compte a bien été modifié !"
                        self.showModalMsg()
                    }
                    else {
                        print("Erreur de numéro de téléphone: nombre de chiffres incorrect ❗️")
                        self.errorLabel.isHidden = false
                        self.errorLabel.text = "Le numéro de téléphone est incorrect"
                    }
                }
                else {
                    print("Erreur de mail: syntaxe incorrecte ❗️")
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = "L'adresse mail est incorrecte"
                }
                
            }
        }
    }
    
    func loadImage() {
        if Auth.auth().currentUser != nil {
            let userUID = Auth.auth().currentUser?.uid
            let refS = Storage.storage().reference()
            let userProfileRef = refS.child("images/profil/" + userUID! + ".png")
            userProfileRef.getData(maxSize: 20 * 1024 * 1024) { data, error in
                if let _ = error {
                    print("🧐 Erreur lors de l'affichage de la photo de profil de: " +  userUID!)
                    self.profilImage.image = UIImage(named: "noImage")
                    //                    print(error)
                } else {
                    let image = UIImage(data: data!)

                    let scaledImage = UIImage.scaleImageToSize(img: image!, size: CGSize(width: 170, height: 170))
                    self.profilImage.image = scaledImage
                }
            }
        }
    }
    
    func showModalMsg() {
        // the alert view
        let alert = UIAlertController(title: "Bravo !", message: "Votre compte a bien été mis à jour.", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    @IBAction func importImage(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        
        self.present(image, animated: true){
        
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            profilImage.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func prenomEditing(_ sender: Any) {
//        prenomField.layer.borderColor = #colorLiteral(red: 0.1858290732, green: 0.8327562213, blue: 0.7390720248, alpha: 1)
//        prenomField.layer.borderWidth = 1.0
//        prenomField.layer.cornerRadius = prenomField.frame.height / 2
//        prenomField.borderStyle = .none
    }
}

