//
//  GaleryViewController.swift
//  PJS4
//
//  Created by Tristan Bilot on 28/03/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class GaleryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var collectionView: UICollectionView!
    var images = [UIImage]()
    var tmpNomEvent: String!
    var tmpOwnerUID: String!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.title = "Galerie photo 🍏"
        loadImages()
        applyStyleToButton()
        
        addButton.layer.shadowColor = Colors.blueBtn.cgColor
        addButton.layer.shadowRadius = 4
        addButton.layer.shadowOpacity = 0.5
        addButton.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func applyStyleToButton() {
        self.addButton.layer.cornerRadius = 20
    }
    
    func loadImages() {
        self.images.removeAll()
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            let refS = Storage.storage().reference()
            ref.child("events").child(tmpOwnerUID!).child(tmpNomEvent).child("galerie").observeSingleEvent(of: .value) { (snapshot) in
                if snapshot.children.allObjects.count <= 0 {
                    self.showEmptyCollectionLabel()
                    return
                }
                for i in 0...snapshot.children.allObjects.count - 1 {
                    let eventImgRef = refS.child("images/eventsGalery/" +  self.tmpOwnerUID! + "/" + self.tmpNomEvent! + "/" + "image" + String(i) + ".png")
                    // Download de l'image
                    eventImgRef.getData(maxSize: 20 * 1024 * 1024) { data, error in // 20 Mo
                        var eventImg:UIImage? = nil
                        if error != nil { // image introuvable, donc affichage de l'image par défaut
                            eventImg = UIImage(named: "failImg")
                            print("🧐 Attention, image d'event introuvable, remplacement par l'image par défaut.")
                        }
                        else {
                            eventImg = UIImage(data: data!)
                        }
                        self.images += [eventImg!]
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func addImagePress(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true){
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            let ref = Database.database().reference()
            let refS = Storage.storage().reference()
            var data = Data()
            data = image.pngData()! // image file name
            ref.child("events").child(tmpOwnerUID!).child(tmpNomEvent).child("galerie").observeSingleEvent(of: .value) { (snapshot) in
                let indice = "image" + String(snapshot.children.allObjects.count)
                /* Insertion image */
                let imageRef = refS.child("images").child("eventsGalery").child(self.tmpOwnerUID!).child(self.tmpNomEvent!).child(indice + ".png")
                _ = imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
                    guard metadata != nil else{
                        print(error as Any)
                        return
                    }
                })
                /* Insertion dans la base de données (pour récupérer le nombre de photos */
                ref.child("events").child(self.tmpOwnerUID!).child(self.tmpNomEvent!).child("galerie").updateChildValues([indice: indice])
                self.images += [image]
                self.collectionView.reloadData()
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func showEmptyCollectionLabel() {
        if collectionView.visibleCells.isEmpty {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            emptyLabel.text = "Galerie photo vide."
            emptyLabel.font = emptyLabel.font.withSize(20)
            emptyLabel.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            emptyLabel.textAlignment = NSTextAlignment.center
            self.collectionView.backgroundView = emptyLabel
        }
    }

//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! GaleryCollectionViewCell
//        if CGAffineTransformEqualToTransform(cell.imageView.transform, CGAffineTransformIdentity) {
//            cell.imageView.transform = CGAffineTransformScale(someView.transform, 2.0, 2.0)
//        } else {
//            cell.imageView.transform = CGAffineTransformIdentity
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! GaleryCollectionViewCell
        
        cell.imageView.image = images[indexPath.item]
        cell.imageView.isUserInteractionEnabled = true
        cell.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleZoomTap)))
        
        return cell
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

