//
//  LaunchScreenAnimationViewController.swift
//  PJS4
//
//  Created by Tristan Bilot on 01/04/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit

class LaunchScreenAnimationViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logo.alpha = 0.3
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        
        UIView.animate(withDuration: 1) {
            self.logo.center.y -= 30
            self.logo.alpha = 1
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
