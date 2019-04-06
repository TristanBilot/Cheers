//
//  BasicButton.swift
//  PJS4
//
//  Created by Tristan Bilot on 22/01/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit

class BasicButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib() // instance de l'interface
        //layer.backgroundColor = StaticVariables.buttonColor.cgColor
        layer.cornerRadius = 18
    }
    
    func changeLabel(label: String) {
        self.setTitle(label, for: .normal)
    }
    
}

//
//  GradientButton.swift
//  PJS4
//
//  Created by Coline FELICIANO on 21/02/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import Foundation
import UIKit

extension UIButton
{
    func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = self.frame.size.height / 2
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
    
