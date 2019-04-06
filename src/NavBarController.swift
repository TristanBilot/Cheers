//
//  NavBarController.swift
//  PJS4
//
//  Created by Tristan Bilot & skezam on 29/01/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import UIKit

class NavBarController: UITabBarController {

    var tabBarIteam = UITabBarItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.orange], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .normal)
        self.tabBar.frame.size.height = 150
        NSLayoutConstraint(item: self.view, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 100).isActive = true
        
        
        
        let selectedImageAdd = UIImage(named: "home2")?.withRenderingMode(.alwaysOriginal)
        let DeSelectedImageAdd = UIImage(named: "home1")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = (self.tabBar.items?[0])!
        tabBarIteam.image = DeSelectedImageAdd
        tabBarIteam.selectedImage = selectedImageAdd
        
        let selectedImageAlert =  UIImage(named: "add2")?.withRenderingMode(.alwaysOriginal)
        let deselectedImageAlert = UIImage(named: "add1")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = (self.tabBar.items?[1])!
        tabBarIteam.image = deselectedImageAlert
        tabBarIteam.selectedImage =  selectedImageAlert
        
        let selectedImageProfile =  UIImage(named: "user2")?.withRenderingMode(.alwaysOriginal)
        let deselectedImageProfile = UIImage(named: "user1")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = (self.tabBar.items?[2])!
        tabBarIteam.image = deselectedImageProfile
        tabBarIteam.selectedImage = selectedImageProfile
        
        let selectedImageHome =  UIImage(named: "heart2")?.withRenderingMode(.alwaysOriginal)
        let deselectedImageHome = UIImage(named: "heart1")?.withRenderingMode(.alwaysOriginal)
        tabBarIteam = (self.tabBar.items?[3])!
        tabBarIteam.image = deselectedImageHome
        tabBarIteam.selectedImage = selectedImageHome
        
        // selected tab background color
        let numberOfItems = CGFloat(tabBar.items!.count)
        _ = CGSize(width: tabBar.frame.width / numberOfItems, height: tabBar.frame.height)
        
        
        
        
        // initaial tab bar index
        self.selectedIndex = 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 30, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
