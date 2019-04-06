//
//  showOneEventViewController.swift
//  PJS4
//
//  Created by Tristan Bilot on 12/03/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import MessageUI

class ShowOneEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var tmpNomEvent: String! // nom récupéré par segue
    var tmpOwnerUID: String! // UID du owner de cet event (segue)
    var participants = [User]()
    var searching = false
    var searchedUsers = [String]()
    
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var viewTableInvit: UITableView!
    @IBOutlet weak var viewProd: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nomEvent: UILabel!
    @IBOutlet weak var commentaire: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var heureDeb: UILabel!
    @IBOutlet weak var heureFin: UILabel!
    @IBOutlet weak var mailInputText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addParticipantBtn: UIButton!
    @IBOutlet weak var addParticipantStackView: UIStackView!
    @IBOutlet weak var sendMailBtn: UIButton!
    @IBOutlet weak var addInvitéShowBtn: UIButton!
    @IBOutlet weak var adresse: UILabel!
    @IBOutlet weak var galeryBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var modifyBtn: UIButton!
    @IBOutlet weak var objectsListBtn: UIButton!
    
    @IBAction func sendMailPress(_ sender: Any) {
        showMailComposer()
    }
    
    @IBAction func shareButton(_ sender: Any) {
        let textToShare = "Découvrez l'évènement " + self.nomEvent.text! + " sur l'application Cheers !\n  - Lieu: " + self.adresse.text! + "\n  - De " + self.heureDeb.text! + " à " + self.heureFin.text! + "\n  - Commentaires: " + self.commentaire.text! + "\n\n"
        let myURL = URL(string: "https://www.google.com")
        let objectToshare = [textToShare, myURL] as [Any]
        let activityVC = UIActivityViewController(activityItems: objectToshare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.postToFacebook]
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
        
    }
    
    func showMailComposer(){
        guard MFMailComposeViewController.canSendMail() else
        {
            return
        }
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["coline.feliciano@hotmail.fr"])
        composer.setSubject("Invitation à l'évènement "  + self.nomEvent.text! + " le " + self.date.text! )
        composer.setMessageBody("Hey ! Je t'invite à mon évènement, va check l'appli Cheers ! ", isHTML: false)
        present(composer, animated: true)
    }
    
    
    struct User {
        var name: String
        var firstName: String
        
        init(name: String, firstName: String) {
            self.name = name
            self.firstName = firstName
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        viewDidLoad()
        participants.removeAll()
        loadParticipants()
        loadImage()
        loadFields()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        addParticipantStackView.isHidden = true
        manageOwnerView()
        applyStyle()
        self.parent?.title = tmpNomEvent
    }
    
    func manageOwnerView() {
        let userUID = Auth.auth().currentUser?.uid
        if userUID != tmpOwnerUID { // si pas owner
            addInvitéShowBtn.isHidden = true
            sendMailBtn.isHidden = true
            modifyBtn.isHidden = true
        }
    }
    
    func applyStyle() {
        self.addInvitéShowBtn.layer.cornerRadius = 18
        self.galeryBtn.layer.cornerRadius = 18
        self.sendMailBtn.layer.cornerRadius = 18
        self.shareBtn.layer.cornerRadius = 18
        self.modifyBtn.layer.cornerRadius = 18
        self.objectsListBtn.layer.cornerRadius = 18
        self.addParticipantBtn.layer.cornerRadius = 18
        self.viewProd.layer.cornerRadius = 10
        self.viewTableInvit.layer.cornerRadius = 10
        self.viewInfo.layer.cornerRadius = 10
        
        objectsListBtn.layer.shadowColor = Colors.rouge.cgColor
        objectsListBtn.layer.shadowRadius = 4
        objectsListBtn.layer.shadowOpacity = 0.5
        objectsListBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        addInvitéShowBtn.layer.shadowColor = Colors.vert.cgColor
        addInvitéShowBtn.layer.shadowRadius = 4
        addInvitéShowBtn.layer.shadowOpacity = 0.5
        addInvitéShowBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        shareBtn.layer.shadowColor = Colors.blueBtn.cgColor
        shareBtn.layer.shadowRadius = 4
        shareBtn.layer.shadowOpacity = 0.5
        shareBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        sendMailBtn.layer.shadowColor = Colors.jaune.cgColor
        sendMailBtn.layer.shadowRadius = 4
        sendMailBtn.layer.shadowOpacity = 0.5
        sendMailBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        galeryBtn.layer.shadowColor = Colors.violet.cgColor
        galeryBtn.layer.shadowRadius = 4
        galeryBtn.layer.shadowOpacity = 0.5
        galeryBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        addParticipantBtn.layer.shadowColor = Colors.bleu.cgColor
        addParticipantBtn.layer.shadowRadius = 4
        addParticipantBtn.layer.shadowOpacity = 0.5
        addParticipantBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    func loadFields() {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            // on a récupéré le nom de l'event grâce au segue entre allEvents et oneEvent, on peut ensuite récupérer les valeurs grâce au nom
            ref.child("events").child(tmpOwnerUID!).child(tmpNomEvent).observeSingleEvent(of: .value) { (snapchot) in
                let value = snapchot.value as? NSDictionary
                self.nomEvent.text = value?["nom"] as? String ?? ""
                self.commentaire.text = value?["commentaire"] as? String ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                self.date.text = value?["date"] as? String ?? ""
                let dateOK = dateFormatter.date(from: self.date.text!)
                dateFormatter.dateFormat = "dd/MM/yyyy"
                self.date.text = dateFormatter.string(from : dateOK!)
                self.heureDeb.text = value?["heureDeb"] as? String ?? ""
                self.heureFin.text = value?["heureFin"] as? String ?? ""
                self.adresse.text = value?["adresse"] as? String ?? ""
            }
        }
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
    
    @IBAction func addInvitéClick(_ sender: Any) {
        if !addParticipantStackView.isHidden {
            UIView.animate(withDuration: 0.4, animations: {
                self.addParticipantStackView.alpha = 0
            }, completion:  {
                (value: Bool) in
                self.addParticipantStackView.isHidden = true
            })
        }
        else {
            self.addParticipantStackView.isHidden = false
            UIView.animate(withDuration: 0.4, animations: {
                self.addParticipantStackView.alpha = 1
            }, completion:  nil)
        }
    }
    
    
    
    
    /* Charge tous les évènements (useless pour le moment) */
    func loadAllEvents() {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            ref.child("events").observeSingleEvent(of: .value) { (snapshot) in
                for snap in snapshot.children {
                    let userSnap = snap as! DataSnapshot
                    let userDict = userSnap.value as! [String:AnyObject] // dictionnaire: liste des events
                    for tuple in userDict {
                        let event = tuple.value as! [String:AnyObject] // nouveau dictionnaire qui contient les infos d'un event
                        let name = event["nom"] as! String
                        print(name)
                    }
                }
            }
        }
    }
    
    /* Charge les personnes invitées à l'évènement dans la tableView */
    
    func loadParticipants() {
        
        var PARTICIPANTS_UIDs = [String]()
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            /* Comptage et listage des UIDs des participants */
//            print("****************"+tmpOwnerUID+"*********"+tmpNomEvent)
            ref.child("events").child(tmpOwnerUID!).child(tmpNomEvent).child("participants").observeSingleEvent(of: .value) { (snapshot) in
                for i in 0...snapshot.children.allObjects.count - 1 { // on enlève un en plus car on a dans la base un participant inutile qui sert a debug
                    let uidList = snapshot.value as? NSDictionary
                    let uid = uidList!["participant" + String(i)] as! String // car dans firebase, la key est 0,1,2...
                    PARTICIPANTS_UIDs.append(uid)
                }
                /* Ajout des participants */
                ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
                    let ALL_UIDs = snapshot.children.allObjects
                    for snap in ALL_UIDs {
                        for uidParticipant in PARTICIPANTS_UIDs {
                            let userSnap = snap as! DataSnapshot
                            let uid = userSnap.key //UID user courant
                            if uid == uidParticipant { /* Comparaison entre le participant courant et le participant a ajouter */
                                let participant = userSnap.value as? NSDictionary
                                let name = participant?["name"] as? String ?? "Un problème est survenu"
                                let firstName = participant?["firstname"] as? String ?? "Un problème est survenu"
                                self.addPersonToTableView(name: name, firstName: firstName)
                            }
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func addParticipantPress(_ sender: Any) {
        let mail = mailInputText.text!
        var found: Bool = false /* Indique si l'adresse est correcte ou non */
        
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
                for snap in snapshot.children {
                    let userSnap = snap as! DataSnapshot
                    let userDict = userSnap.value as! [String:AnyObject]
                    let currentMail = userDict["mail"] as! String
                    if currentMail == mail {
                        found = true
                        let name = userDict["name"] as! String
                        let firstName = userDict["firstname"] as! String
                        let uidParticipant = userSnap.key // nom du folder: l'uid
                        
                        if self.isAlreadyInTheTable(name: name, firstName: firstName) {
                            self.showModalMsg("Vous avez déjà invité cette personne !", title_: "🎉")
                            return
                        }
                        else {
                            self.addPersonToTableView(name: name, firstName: firstName) // ajout
                            ref.child("events").child(self.tmpOwnerUID!).child(self.tmpNomEvent!).child("participants").observeSingleEvent(of: .value) { (snapshot) in
                                // insertion uniquement lorsque le user n'est pas déjà inscrit
                                let indice = "participant" + String(snapshot.children.allObjects.count)
                                /* !! Utiliser updateChildValues à la place de setValue lors d'un ajout, setValue va effacer les vieilles values */
                                ref.child("events").child(self.tmpOwnerUID!).child(self.tmpNomEvent!).child("participants").updateChildValues([indice: uidParticipant])
                                
                            }
                        }
                        
                        
                        
                    }
                }
                if found {
                    self.tableView.reloadData()
                }
                else {
                    self.showModalMsg("Vérifiez la syntaxe de l'adresse 😉", title_: "Adresse email introuvable !")
                }
            }
        }
        mailInputText.text = ""
    }
    
    func isAlreadyInTheTable(name: String, firstName: String) -> Bool {
        for user in participants {
            if user.firstName == firstName && user.name == name {
                return true
            }
        }
        return false
    }
    
    /* --------- Fonctions TableView ---------- */
    func addPersonToTableView(name: String, firstName: String) {
        self.participants.append(User.init(name: name, firstName: firstName))
        print(participants)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell")
        let fullName = participants[indexPath.row].firstName + " " + participants[indexPath.row].name
        cell!.textLabel?.text = fullName
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    /* ---------- Fin fonctions TableView ---------- */
    
    //    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //        loadAllUsers(success: printData(data:))
    //    }
    
    
    
    func showModalMsg(_ message_: String, title_: String) {
        // the alert view
        let alert = UIAlertController(title: title_, message: message_, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ModifyEventViewController
        {
            if let controller = segue.destination as? ModifyEventViewController {
                controller.tmpNomEvent = self.tmpNomEvent
                controller.tmpOwnerUID = self.tmpOwnerUID
            }
            else
            { print("let problem")}
        }
        else if segue.destination is GaleryViewController {
            if let controller = segue.destination as? GaleryViewController {
                controller.tmpNomEvent = self.tmpNomEvent
                controller.tmpOwnerUID = self.tmpOwnerUID
            }
            else
            { print("let problem")}
        }
        else if segue.destination is ListeObjetsViewController
        {
            if let controller = segue.destination as? ListeObjetsViewController {
                controller.tmpNomEvent = self.tmpNomEvent
                controller.tmpOwnerUID = self.tmpOwnerUID
            }
            else
            { print("let problem")}
        }
        else
        { print("segue problem --> ShowOneEvent")}

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
}

extension ShowOneEventViewController : MFMailComposeViewControllerDelegate{
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error{
            controller.dismiss(animated:true)
            return
        }
        switch result{
        case .cancelled:
            print("Cancelled")
        case .failed:
            print("Failed to send")
        case .saved:
            print("Saved")
        case .sent:
            print("Email sent")
        }
        controller.dismiss(animated : true)
    }
}

//protocol LoadUsersDelegate {
//    func printData(data:[String])
//}



