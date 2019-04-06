//
//  viewControlerTest.swift
//  PJS4
//
//  Created by Coline FELICIANO on 02/04/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import MBCircularProgressBar
import FirebaseAuth

class viewControlerTest: UIViewController {
    var time = Timer()
    
    @IBOutlet weak var progressCircle: MBCircularProgressBarView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // time = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(viewControlerTest.update), userInfo: nil, repeats: true)
        
        self.progressCircle.value = 0
        //  sleep(2)
        
        
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIView.animate(withDuration: 2.0, animations: {
            self.progressCircle.value = 100
        }) { (true) in
            if Auth.auth().currentUser != nil { // si connecté, redirection vers les event
                self.performSegue(withIdentifier: "goEventsFromStartup", sender: nil)
            }
            else { // sinon, connexion
                self.performSegue(withIdentifier: "GoToStartUp", sender: self)
            }
        }
    }
    @IBOutlet weak var progressBar: UIProgressView!
    
    /* @objc func update(){
     progressBar.progress += 0.03
     if progressBar.progress == 1{
     time.invalidate()
     performSegue(withIdentifier: "GoToStartUp", sender: nil)
     
     }
     */
}



/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */



