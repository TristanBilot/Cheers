//
//  ViewController.swift
//  PJS4
//
//  Created by Tristan Bilot on 22/01/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit
import FirebaseAuth

class FirstPage: UIViewController {

    @IBOutlet weak var inscriptionBtn: BasicButton!
    @IBOutlet weak var connexionBtn: BasicButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFirstPage()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.shadowImage = UIImage()
        
    }

    private func initFirstPage() {
        self.view.backgroundColor = StaticVariables.background
    }

}
