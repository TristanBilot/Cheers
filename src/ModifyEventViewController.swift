// ModifyEventViewController.swift
//  PJS4
//
//  Created by Aroun rdj on 28/03/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ModifyEventViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var tmpNomEvent: String! // nom récupéré par segue
    var tmpOwnerUID: String! // UID du owner de cet event (segue)

    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nomEvent: UITextField!
    @IBOutlet weak var date: UITextField!
    @IBOutlet weak var heureDeb: UITextField!
    @IBOutlet weak var heureFin: UITextField!
    @IBOutlet weak var commentaire: UITextField!
    @IBOutlet weak var changeAdressBtn: UIButton!
    @IBOutlet weak var validerBtn: UIButton!
    
    @IBOutlet weak var adresseBtnImg: UIButton!
    private var datePicker : UIDatePicker?
    private var timePicker : UIDatePicker?
    private var timePickerEnd : UIDatePicker?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFields()
        loadImage()
        datePicker = UIDatePicker()
        timePicker = UIDatePicker()
        timePickerEnd = UIDatePicker()
        datePicker?.datePickerMode = .date
        timePicker?.datePickerMode = .time
        timePickerEnd?.datePickerMode = .time
        
        datePicker?.addTarget(self, action: #selector(CreateEventViewController.dateChanged(datePicker:)), for: .valueChanged)
        timePicker?.addTarget(self, action: #selector(CreateEventViewController.timeChanged(timePicker:)), for: .valueChanged)
        timePickerEnd?.addTarget(self, action: #selector(CreateEventViewController.timeChangedEnd(timePickerEnd:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self
            , action: #selector(CreateEventViewController.viewTaped(GestureRecognizer:)))
        
        view.addGestureRecognizer(tapGesture)
        date.inputView = datePicker
        heureDeb.inputView = timePicker
        heureFin.inputView = timePickerEnd
//        image.layer.cornerRadius = 40
        image.clipsToBounds = true
        image.isUserInteractionEnabled = true
        
        changeAdressBtn.layer.cornerRadius = changeAdressBtn.frame.height / 2
        adresseBtnImg.layer.zPosition = 3
        
        validerBtn.layer.cornerRadius = validerBtn.frame.height / 2
        
        self.commentaire.delegate = self
        
        validerBtn.layer.shadowColor = Colors.blueBtn.cgColor
        validerBtn.layer.shadowRadius = 4
        validerBtn.layer.shadowOpacity = 0.5
        validerBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        // Do any additional setup after loading the view.
    }
    
    
    private func initializeFields() {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            ref.child("events").child(tmpOwnerUID!).child(tmpNomEvent!).observeSingleEvent(of: .value) { (snapchot) in
                let value = snapchot.value as? NSDictionary
                let nom = value?["nom"] as? String ?? ""
                let date = value?["date"] as? String ?? ""
                let heureDeb = value?["heureDeb"] as? String ?? ""
                let heureFin = value?["heureFin"] as? String ?? ""
                let commentaire = value?["commentaire"] as? String ?? ""
                self.nomEvent.text = nom
                self.date.text = date
                self.heureDeb.text = heureDeb
                self.heureFin.text = heureFin
                self.commentaire.text = commentaire
            }
        }
    }
    
    @objc func viewTaped (GestureRecognizer : UITapGestureRecognizer){
        view.endEditing(false)
    }
    
    @objc func dateChanged(datePicker : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        date.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(false)
    }
    
    @objc func timeChanged(timePicker : UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        heureDeb.text = formatter.string(from: timePicker.date)
    }
    
    @objc func timeChangedEnd(timePickerEnd : UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        heureFin.text = formatter.string(from: timePickerEnd.date)
    }
    
    
    @IBAction func addImage(_ sender: Any) {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true){
            
        }
    }
    
    @IBAction func updateEvent(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            
            let storage = Storage.storage()
            var data = Data()
            data = self.image.image!.pngData()! // image file name
            let storageRef = storage.reference()
            
            
            let imageRef = storageRef.child("images/events/" + self.tmpOwnerUID + "/" + self.tmpNomEvent + ".png")
            _ = imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
                guard metadata != nil else{
                    print(error as Any)
                    return
                }
            })
            
            let ref = Database.database().reference()
            ref.child("events").child(tmpOwnerUID!).child(tmpNomEvent!).updateChildValues(["nom": self.nomEvent.text!, "date": self.date.text!, "heureDeb": self.heureDeb.text!, "heureFin": self.heureFin.text!, "commentaire": self.commentaire.text!])
            //IL MANQUE L'ADRESSE
            //ref.child("events").child(tmpOwnerUID!).child(tmpNomEvent!).observeSingleEvent(of: .value) { (snapchot) in
            
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    func loadImage() {
        if Auth.auth().currentUser != nil {
            let ref = Storage.storage().reference()
            let userProfilesRef = ref.child("images/events/" +  tmpOwnerUID! + "/" + tmpNomEvent + ".png")
            // Download de l'image
            userProfilesRef.getData(maxSize: 6 * 1024 * 1024) { data, error in // 6 Mo
                if let _ = error {
                    print("🧐 Erreur lors de l'affichage de l'image de l'event: " +  self.tmpNomEvent)
                    self.image.image = UIImage(named: "noImage")
                    self.image.contentMode = .scaleAspectFit
                } else {
                    let image = UIImage(data: data!)
                    self.image.image = image // affichage de l'image
                    self.image.contentMode = .scaleAspectFit
                    
                    self.image.isUserInteractionEnabled = true
                    self.image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleZoomTap)))
                }
            }
        }
    }
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        print("ok")
        if let imageView = tapGesture.view as? UIImageView {
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            performZoomInForStartingImageView(imageView)
        }
    }
    
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.image.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ShowOneEventViewController
        {
            if let controller = segue.destination as? ShowOneEventViewController {
                controller.tmpNomEvent = self.tmpNomEvent
                controller.tmpOwnerUID = self.tmpOwnerUID
            }
            else
            { print("let problem")}
        }
        else if segue.destination is UINavigationController {
            let destinationNavigationController = segue.destination as! UINavigationController
            let controller = destinationNavigationController.topViewController as! MapViewController
            controller.modeUpdate = true
            controller.nomSoirée = self.tmpNomEvent
            controller.ownerID = self.tmpOwnerUID
                        
        }
        else
        { print("segue problem --> ShowOneEvent or MapViewController")}
    }
    
}
