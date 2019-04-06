//
//  CompteView.swift
//  PJS4
//
//  Created by Tristan Bilot on 24/01/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class CompteView: UIViewController {

    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var NomLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var EventView: UIButton!
    @IBOutlet weak var modifCompteBtn: BasicButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var `switch`: UISwitch!
    
    
    @IBAction func switchLogOut(_ sender: UISwitch) {
        if(sender.isOn == false) {
            try! Auth.auth().signOut()
            if let storyboard = self.storyboard {
                let vc = storyboard.instantiateViewController(withIdentifier: "FirstPage") as! UINavigationController
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelShowState(state: false)
        modifCompteBtn.layer.cornerRadius = 20
//        self.image.layer.cornerRadius = self.image.frame.width / 2
        self.switch.onTintColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        progressImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Mon compte"
        loadImage()
        initializeLabels()
    }
    
    private func initializeLabels() {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            let userUID = Auth.auth().currentUser?.uid
            ref.child("users").child(userUID!).observeSingleEvent(of: .value) { (snapchot) in
                let value = snapchot.value as? NSDictionary
                let mail = value?["mail"] as? String ?? ""
                let firstname = value?["firstname"] as? String ?? ""
                let name = value?["name"] as? String ?? ""
                let phone = value?["phone"] as? String ?? ""
                self.emailLabel.text = mail
                self.NomLabel.text = name
                self.firstNameLabel.text = firstname
                self.phoneLabel.text = String(phone)
                
                
                }
            }
        }
    
    func loadImage() {
        if Auth.auth().currentUser != nil {
            let userUID = Auth.auth().currentUser?.uid
            let refS = Storage.storage().reference()
            let userProfileRef = refS.child("images/profil/" + userUID! + ".png")
            userProfileRef.getData(maxSize: 20 * 1024 * 1024) { data, error in // 6 Mo
                if let _ = error {
                    print("🧐 Erreur lors de l'affichage de la photo de profil de: " +  userUID!)
                    self.image.image = UIImage(named: "noImage")
                    //                    print(error)
                } else {
                    let image = UIImage(data: data!)
                    
                    let scaledImage = UIImage.scaleImageToSize(img: image!, size: CGSize(width: 170, height: 170))
                    self.image.image = scaledImage
                    self.image.layer.cornerRadius = self.image.frame.width / 2
                    self.image.clipsToBounds = true
                    self.image.layer.borderColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1).cgColor
                    self.image.layer.borderWidth = 4
                    self.image.contentMode = .scaleAspectFit
                    self.image.isUserInteractionEnabled = true
                    self.image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleZoomTap)))
                    
                }
            }
        }
    }
    
    func progressImage() {
        activity.startAnimating()
        activity.layer.zPosition = -1
    }
    
    // sert à cacher les fields avant leur initialisation
    private func labelShowState(state: Bool) {
        emailLabel.isHidden = state
        NomLabel.isHidden = state
        firstNameLabel.isHidden = state
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        if let imageView = tapGesture.view as? UIImageView {
            performZoomInForStartingImageView(imageView)
        }
    }
    
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor?.withAlphaComponent(0)
        zoomingImageView.contentMode = .scaleAspectFit
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //                    do nothing
            })
            
        }
    }
    
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
}

extension UIImage {
    
    class func scaleImageToSize(img: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        
        img.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
}
