//
//  MapViewController.swift
//  PJS4
//
//  Created by Tristan Bilot on 19/02/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class MapViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    
    var locationManager: CLLocationManager!
    var mapView: MKMapView!
    var adressOfParty: String!
    var heureFin: String!
    var heureDeb: String!
    var nomSoirée: String!
    var date: String!
    var commentaire: String!
    var image: UIImageView!
    var modeUpdate: Bool!
    var ownerID: String!
    
    let centerMapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("VALIDER", for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.bold()
        button.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        button.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        button.titleLabel?.font = button.titleLabel?.font.withSize(20)
        button.widthAnchor.constraint(equalToConstant: 200)
        //button.setImage(#imageLiteral(resourceName: "Image").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCenterLocation), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        configureMapView()
        enableLocationServices()
        sleep(1)
        showModalMsg("Ou se déroulera votre évènement ?", title_: "Lieu")
    }

    
    
    @objc func handleCenterLocation() {
        validateAdressPress()
    }
    
    func validateAdressPress() {
        if adressOfParty == nil {
            showModalMsg("Sans adressse, compliqué d'organiser une soirée 🤨", title_: "Tu as oublié quelque chose")
            return
        } else {
            let ref = Database.database().reference()
            let UserID = Auth.auth().currentUser?.uid
            if modeUpdate {
                ref.child("events").child(ownerID!).child(nomSoirée!).updateChildValues(["adresse":self.adressOfParty!])
                dismiss(animated: true, completion: nil)
            } else {
                
                /* Insertion de l'image dans la bdd storage Firebase */
                let storage = Storage.storage()
                var data = Data()
                data = self.image.image!.pngData()! // image file name
                let storageRef = storage.reference()
                let imageRef = storageRef.child("images/events/" + UserID! + "/" + nomSoirée! + ".png")
                _ = imageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
                    guard metadata != nil else{
                        print(error as Any)
                        return
                    }
                })
                /* Insertion des valeurs dans la bdd */
                ref.child("events").child(UserID!).child(nomSoirée!).setValue(["nom": self.nomSoirée!, "date": self.date!, "heureDeb": self.heureDeb!, "heureFin": self.heureFin!, "adresse": self.adressOfParty!, "commentaire": self.commentaire!])
                print("Event créé ✅")
                
                ref.child("events").child(UserID!).child(nomSoirée!).child("participants").observeSingleEvent(of: .value) { (snapshot) in
                    /* Ajout du ueseless pour formater le folder participants en clé-valeur et pour pouvoir y accéder pour l'affichage */
                    //                ref.child("events").child(UserID!).child(self.nomSoirée!).child("participants").setValue(["useless": "useless"])
                    let indice = "participant" + String(snapshot.children.allObjects.count) // l'identifiant de participant : dernier numéro + 1, commence à 0
                    /* Création du folder 'participants' et ajout du créateur de l'event */
                    ref.child("events").child(UserID!).child(self.nomSoirée!).child("participants").setValue([indice: UserID!])
                }
                
                /* Segue pour changer de page */
                performSegue(withIdentifier: "mapToMenuSegue", sender: nil)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func configureMapView() {
        mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        /* Positionnement du bouton valider */
        view.addSubview(centerMapButton)
        centerMapButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -44).isActive = true
        centerMapButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        centerMapButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        centerMapButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -view.frame.width / 2 + 200 / 2).isActive = true
        centerMapButton.layer.cornerRadius = 50 / 2
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.centerMapButton.alpha = 1
        }
    }
    
}

// MARK: - CLLocationManagerDelegate

extension MapViewController: CLLocationManagerDelegate {
    
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("Location auth status is NOT DETERMINED")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location auth status is RESTRICTED")
        case .denied:
            print("Location auth status is DENIED")
        case .authorizedAlways:
            print("Location auth status is AUTHORIZED ALWAYS")
        case .authorizedWhenInUse:
            print("Location auth status is AUTHORIZED WHEN IN USE")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard locationManager.location != nil else { return }
        centerMapOnUserLocation()
    }
    
    // search bar
    
    @IBAction func searchButton(_ sender: Any)
    {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "L'adresse de l'évènement 📍"
        present(searchController, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.adressOfParty = searchBar.text!
        //Ignoring user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //Activity Indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        self.view.addSubview(activityIndicator)
        
        //Hide search bar
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        //Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { (response, error) in
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if response == nil
            {
                print("ERROR")
            }
            else
            {
                //Remove annotations
                let annotations = self.mapView.annotations
                self.mapView.removeAnnotations(annotations)
                
                //Getting data
                let latitude = response?.boundingRegion.center.latitude
                let longitude = response?.boundingRegion.center.longitude
                
                //Create annotation
                let annotation = MKPointAnnotation()
                annotation.title = searchBar.text
                annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                self.mapView.addAnnotation(annotation)
                
                //Zooming in on annotation
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
            }
            
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    @IBAction func cancelButton(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }

}
