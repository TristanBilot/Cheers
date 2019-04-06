//
//  ShowEventsViewController.swift
//  PJS4
//
//  Created by Tristan Bilot on 05/02/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

var selectedEvent = "" // L'event qui est sélectionné au clic, pour envoi au segue
var selectedEventOwnerUID = ""

class ShowEventsViewController: UITableViewController {
    
    var eventsName = [String]()
    var eventsDate = [String]()
    var eventsLieu = [String]()
    var eventsOwner = [Bool]() /* Booléen qui défini si le user est le owner */
    var eventsImg = [UIImage?]()
    var eventsOwnerUid = [String]()
    var eventsID = [String]()
    @IBOutlet weak var noEventsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.navigationItem.title = "Mes évènements"
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
        self.tabBarController?.tabBar.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        tableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        purgeArrays()
        loadEventsOwner()
        loadEventsParticipants()
    }
    
    /* Charge dans la table les event du propriétaire */
    func loadEventsOwner() {
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            let userUID = Auth.auth().currentUser?.uid
            ref.child("events").child(userUID!).observeSingleEvent(of: .value) { (snapshot) in
                let enumerator = snapshot.children // nombre de tuples
                while let rest = enumerator.nextObject() as? DataSnapshot { // boucle sur tous les tuples
                    let tuple = rest.value as! [String: Any]  // pour accéder au tableau des values
                    let name = tuple["nom"] as? String
                    let date = tuple["date"] as? String
                    let lieu = tuple["adresse"] as? String
                    
                    let refS = Storage.storage().reference()
                    let eventImgRef = refS.child("images/events/" +  userUID! + "/" + rest.key + ".png")
                    // Download de l'image
                    eventImgRef.getData(maxSize: 20 * 1024 * 1024) { data, error in // 20 Mo
                        var eventImg:UIImage? = nil
                        if error != nil { // image introuvable, donc affichage de l'image par défaut
                            eventImg = UIImage(named: "noImage")
                            print("🧐 Attention, image d'event introuvable, remplacement par l'image par défaut.")
                        }
                        else {
                            eventImg = UIImage(data: data!)
                        }
                        
                        self.eventsID += [rest.key]
                        self.eventsOwnerUid += [userUID!] // car c'est le owner
                        self.eventsImg += [eventImg]
                        self.eventsName += [name!]
                        self.eventsDate += [date!]
                        self.eventsLieu += [lieu!]
                        self.eventsOwner += [true] // le user est le owner car on regarde ses soirées
                        self.tableView.reloadData()
                    }
                }
                 // Très important ! Il faut refraîchir les data sinon ça ne fera rien
            }
        }
    }
    
    /* Charge dans la table les event ou le user est invité */
    func loadEventsParticipants() {
        
        if Auth.auth().currentUser != nil {
            let ref = Database.database().reference()
            let UserID = Auth.auth().currentUser?.uid
            ref.child("events").observeSingleEvent(of: .value) { (eventsSnapshot) in
                for tuple1 in eventsSnapshot.children { // parcours tous les events (uid)
                    let userSnap1 = tuple1 as! DataSnapshot
                    let currentEventUID = userSnap1.key // nom du folder: l'uid
                    
                    ref.child("events").child(currentEventUID).observeSingleEvent(of: .value) { (eventsValuesSnapchot) in
                        for tuple2 in eventsValuesSnapchot.children { // parcours tous les events (nom)
                            let userSnap2 = tuple2 as! DataSnapshot
                            let userDict2 = userSnap2.value as! [String:AnyObject] // events
                            print(userDict2["nom"] as! String)
                            let currentEventName = userDict2["nom"] as! String
                            let currentEventDate = userDict2["date"] as! String
                            let currentEventLieu = userDict2["adresse"] as! String
                            
                            ref.child("events").child(currentEventUID).child(userSnap2.key).child("participants").observeSingleEvent(of: .value) { (participantsSnapchot) in
                                for i in 0...participantsSnapchot.children.allObjects.count - 1  { // parcours tous les participants
                                    let userDict3 = participantsSnapchot.value as! NSDictionary // events
                                    let currentParticipantUID = userDict3["participant" + String(i)] as! String // participant0, participant1 etc..
                                    if currentParticipantUID == UserID! { // si on trouve l'uid du user dans un event
                                        if UserID != currentEventUID {
                                            let refS = Storage.storage().reference()
                                            let eventImgRef = refS.child("images/events/" +  currentEventUID + "/" + userSnap2.key + ".png")
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
                                                self.eventsID += [userSnap2.key]
                                                self.eventsOwnerUid += [currentEventUID] // uid du créateur
                                                self.eventsImg += [eventImg]
                                                self.eventsName += [currentEventName]
                                                self.eventsDate += [currentEventDate]
                                                self.eventsLieu += [currentEventLieu]
                                                self.eventsOwner += [false] // pas owner de l'event
                                                self.tableView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
    }
 
    //
    func compareDate( dateEvent : String) -> Bool{
        let formater = DateFormatter()
        formater.dateFormat = "MM/dd/yyyy"
        
        let dConvertie = formater.date(from: dateEvent)! as Date
        if (dConvertie < Date()){
            return true
        }
        else{
            return false
        }
    }
    
    // ECART DES DATES
    func compareDateNew ( dateEvent : String) -> Bool{
        let formater = DateFormatter()
        formater.dateFormat = "MM/dd/yyyy"
        
        let dConvertie = formater.date(from: dateEvent)! as Date
        let calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: dConvertie)
        let date2 = calendar.startOfDay(for: Date())
        
        let cal = NSCalendar.current
        
        
        let components = cal.dateComponents([.day], from: date2, to: date1)
        if (( components.day! < 7 && components.day! > 0) || components.day == 0 ){
            
            return true
        }
        else {
            return false
        }
    }
    
    func jourRestants( dateEvent : String) -> Int {
        let formater = DateFormatter()
        formater.dateFormat = "MM/dd/yyyy"
        
        let dConvertie = formater.date(from: dateEvent)! as Date
        let calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: dConvertie)
        let date2 = calendar.startOfDay(for: Date())
        
        let cal = NSCalendar.current
        
        
        let components = cal.dateComponents([.day], from: date2, to: date1)
        return components.day!
    }
    
    func purgeArrays() {
        eventsDate.removeAll() // Il faut purger les data à chaque refraîcihissement sinon accumulation
        eventsName.removeAll()
        eventsOwnerUid.removeAll()
        eventsImg.removeAll()
        eventsOwner.removeAll()
        eventsLieu.removeAll()
        eventsID.removeAll()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
        
        /* Refresh des caractéristiques des cells */
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // dégriser
        cell.isUserInteractionEnabled = true
        cell.messageView.textColor = #colorLiteral(red: 0.1562257409, green: 0.1944119632, blue: 0.2741214931, alpha: 1)
        cell.soonView.isHidden = true
        cell.soonView.text = ""
//        cell.soonView.rightAnchor.constraint(equalTo : cell.rightAnchor).isActive = false
//        cell.soonView.leftAnchor.constraint(equalTo : cell.mainImageView.rightAnchor, constant: 0).isActive = true
//        cell.soonView.topAnchor.constraint(equalTo : cell.topAnchor, constant: 0).isActive = true
//        cell.soonView.bottomAnchor.constraint(equalTo:cell.messageView.topAnchor).isActive = false
        /* ------------------------ */
        
        cell.nameEvent = self.eventsName[indexPath.row]
        cell.dateEvent = self.eventsDate[indexPath.row]
        cell.lieuEvent = self.eventsLieu[indexPath.row]
        cell.mainImage = self.eventsImg[indexPath.row]
        cell.uidOwner = self.eventsOwnerUid[indexPath.row]
        cell.idEvent =  self.eventsID[indexPath.row]
        if self.eventsOwner[indexPath.row] {
            cell.ownerImg = #imageLiteral(resourceName: "star") // étoile
        }
        else if self.eventsOwner[indexPath.row] == false {
            cell.ownerImg = #imageLiteral(resourceName: "invite") // invitation
        }
        
        /* Griser quand date dépassée */
        if (self.compareDate(dateEvent : cell.dateEvent!)) {
            cell.isUserInteractionEnabled = false
            cell.backgroundColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1) // griser
            cell.messageView.textColor = UIColor.black
        }
        
        /* Mettre Bientôt pour les évènements proches */
        if (self.compareDateNew(dateEvent : cell.dateEvent!)) {
            let jrRestants = self.jourRestants(dateEvent: cell.dateEvent!)
            if (jrRestants == 1){
                cell.soonView.text = "Dans \(jrRestants) jour !"
            }
            else if (jrRestants == 0){
                cell.soonView.text = "Aujourd'hui !"
            }
            else{
                cell.soonView.text = "Dans \(jrRestants) jours !"
                
            }
            cell.soonView.isHidden = false
        }
        
        cell.layoutSubviews()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if Auth.auth().currentUser != nil {
                let ref = Database.database().reference()
                 let storage = Storage.storage()
                let storageRef = storage.reference()
                let UserID = Auth.auth().currentUser?.uid
                
                if UserID == self.eventsOwnerUid[indexPath.row] {
                    
                    let alert = UIAlertController(title: "Avertissement, vous êtes l'organisateur ! ", message: "Voulez-vous supprimer l'évènement et ce pour tout le monde ?", preferredStyle: UIAlertController.Style.alert)
                    
                    //CREATING ON BUTTON
                    alert.addAction(UIAlertAction(title: "Oui", style: UIAlertAction.Style.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                        self.eventsName.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        ref.child("events").child(self.eventsOwnerUid[indexPath.row]).child(self.eventsID[indexPath.row]).removeValue()
                        let imageSupp = storageRef.child("images/events/" + self.eventsOwnerUid[indexPath.row] + "/" + self.eventsID[indexPath.row] + ".png")
                        imageSupp.delete { (error) in
                            print(error as Any)
                            return
                        }
                        
//                        self.eventsName.remove(at: indexPath.row)
//                        tableView.deleteRows(at: [indexPath], with: .fade)
                        self.viewDidAppear(true)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Non", style: UIAlertAction.Style.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                    self.tableView.reloadData()
                    
                }else {
                    let alert = UIAlertController(title: "Avertissement", message: "Voulez-vous être retiré des participants ?", preferredStyle: UIAlertController.Style.alert)
                    
                    //CREATING ON BUTTON
                    alert.addAction(UIAlertAction(title: "Oui", style: UIAlertAction.Style.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                        self.eventsName.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        
                        ref.child("events").child(self.eventsOwnerUid[indexPath.row]).child(self.eventsID[indexPath.row]).child("participants").observeSingleEvent(of: .value) { (snapshot) in
                            let ite = snapshot.children.allObjects.count - 1
                            for i in 0...ite {
                                let uidList = snapshot.value as? NSDictionary
                                let uid = uidList!["participant" + String(i)] as! String // car dans firebase, la key est 0,1,2...
                                if uid == UserID {
                                    ref.child("events").child(self.eventsOwnerUid[indexPath.row]).child(self.eventsID[indexPath.row]).child("participants").child("participant" + String(i)).removeValue()
                                    if !(i == ite){
                                        for j in i...ite-1 {
                                            let uidList = snapshot.value as? NSDictionary
                                            let uid = uidList!["participant" + String(j+1)] as! String
                                            ref.child("events").child(self.eventsOwnerUid[indexPath.row]).child(self.eventsID[indexPath.row]).child("participants").updateChildValues(["participant" + String(j): uid])
                                            ref.child("events").child(self.eventsOwnerUid[indexPath.row]).child(self.eventsID[indexPath.row]).child("participants").child("participant" + String(j+1)).removeValue()
                                        }
                                    }
                                    
                                    break
                                }
                            }
                            self.tableView.reloadData()
                            
                            self.viewDidAppear(true)
                        }
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Non", style: UIAlertAction.Style.default, handler: { (action) in
                        alert.dismiss(animated: true, completion: nil)
                        
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
   
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsName.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! CustomCell
        selectedEvent = currentCell.idEvent!
        selectedEventOwnerUID = currentCell.uidOwner!
        self.performSegue(withIdentifier: "ShowOneEventViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ShowOneEventViewController
        {
            if let controller = segue.destination as? ShowOneEventViewController {
                controller.tmpNomEvent = selectedEvent
                controller.tmpOwnerUID = selectedEventOwnerUID
            }
            else
            { print("let problem")}
        }
        else
        { print("segue problem --> ShowOneEvent")}
    }
    
//        func checkTableViewIsEmpty() {
//            tableView.reloadData()
//            if tableView.visibleCells.isEmpty {
//                var emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
//                emptyLabel.text = "No Data"
//                emptyLabel.textAlignment = NSTextAlignment.center
//                self.tableView.backgroundView = emptyLabel
//                self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
//            }
//        }
}
