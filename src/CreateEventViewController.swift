//
//  CreateEventViewController.swift
//  PJS4
//
//  Created by Tristan Bilot on 05/02/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class CreateEventViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var suivantBtn: BasicButton!
    @IBOutlet weak var heureFin: UITextField!
    @IBOutlet weak var heureDebut: UITextField!
    @IBOutlet weak var textDate: UITextField!
    private var datePicker : UIDatePicker?
    private var timePicker : UIDatePicker?
    private var timePickerEnd : UIDatePicker?
    @IBOutlet weak var decorView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nameEvent: UITextField!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var commentaire: UITextField!
    
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
            eventImage.image = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managePickers()
        self.nameEvent.delegate = self
        self.commentaire.delegate = self
        
        suivantBtn.layer.shadowColor = Colors.blueBtn.cgColor
        suivantBtn.layer.shadowRadius = 4
        suivantBtn.layer.shadowOpacity = 0.5
        suivantBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        
//        self.decorView.layer.borderColor = #colorLiteral(red: 0.3455736041, green: 0.4283797145, blue: 0.5053092837, alpha: 1)
//        self.decorView.layer.borderWidth = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Créer un évènement"
    }
    
    func managePickers() {
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
        textDate.inputView = datePicker
        heureDebut.inputView = timePicker
        heureFin.inputView = timePickerEnd
        eventImage.layer.cornerRadius = 40
        eventImage.clipsToBounds = true
        eventImage.isUserInteractionEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameEvent.resignFirstResponder()
        commentaire.resignFirstResponder()
        return true
    }
    
    @objc func viewTaped (GestureRecognizer : UITapGestureRecognizer){
        view.endEditing(false)
    }
    @objc func dateChanged(datePicker : UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        textDate.text = dateFormatter.string(from: datePicker.date)
        view.endEditing(false)
    }
    
    @objc func timeChanged(timePicker : UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        heureDebut.text = formatter.string(from: timePicker.date)
    }
    
    @objc func timeChangedEnd(timePickerEnd : UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        heureFin.text = formatter.string(from: timePickerEnd.date)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
         // envoyer les data a la carte pour qu'elle les envoie a la bdd
        if nameEvent.text!.isEmpty || textDate.text!.isEmpty || heureDebut.text!.isEmpty || heureFin.text!.isEmpty {
            showModalMsg("Vous avez oublié un champ 🧐", title_: "Oups !")
            return
        }
        
        if segue.destination is UINavigationController
        {
            let destinationNavigationController = segue.destination as! UINavigationController
            let controller = destinationNavigationController.topViewController as! MapViewController
            controller.heureFin = heureDebut.text!
            controller.heureDeb = heureDebut.text!
            controller.commentaire = commentaire.text!
            controller.date = textDate.text!
            controller.image = eventImage
            controller.nomSoirée = nameEvent.text!
            controller.modeUpdate = false
        }
        else
        { print("segue problem")}
        
        
        if let imageData = eventImage.image!.pngData() {
            let bytes = imageData.count
            let KB = Double(bytes) / 1024.0 // Note the difference
            if KB > 5000 {
                showModalMsg("Veuillez choisir une autre image ! (Moins de 5Mo) ", title_: "Image trop lourde")
            }
        }
    }
    
    func showModalMsg(_ message_: String, title_: String) {
        let alert = UIAlertController(title: title_, message: message_, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
    }

}
