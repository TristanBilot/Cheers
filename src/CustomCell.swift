//
//  CustomCell.swift
//  PJS4
//
//  Created by Flo on 12/02/2019.
//  Copyright © 2019 Tristan Bilot. All rights reserved.
//

import Foundation
import UIKit


class CustomCell: UITableViewCell{
    var mainImage: UIImage?
    var nameEvent : String?
    var dateEvent: String?
    var lieuEvent: String?
    var ownerImg: UIImage?
    var uidOwner: String?
    var soonLabel : String?
    var idEvent : String?
    
    var messageView : UILabel = { // Nom de l'event: label
        var textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints=false
        textView.font = textView.font.withSize(18)
        textView.textColor = #colorLiteral(red: 0.1562257409, green: 0.1944119632, blue: 0.2741214931, alpha: 1)
        textView.font = textView.font.bold()
        return textView
    }()
    
    var dateView : UILabel = {
        var textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints=false
        textView.font = textView.font.withSize(14)
        return textView
    }()
    
    var lieuView : UILabel = {
        var textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints=false
        textView.font = textView.font.withSize(14)
        return textView
    }()
    
    var mainImageView : UIImageView = { // Image de l'event: image
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints=false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var ownerView : UIImageView = { // Image de l'event: image
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints=false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var uidOwnerView : UILabel = {
        var textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints=false
        textView.font = textView.font.withSize(14)
        textView.isHidden = true
        return textView
    }()
    
    var idEventView : UILabel = {
        var textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints=false
        textView.font = textView.font.withSize(14)
        textView.isHidden = true
        return textView
    }()
    
    var soonView : UILabel = {
        var textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints=false
        textView.font = textView.font.withSize(16)
        textView.textColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(mainImageView)
        self.addSubview(messageView)
        self.addSubview(dateView)
        self.addSubview(lieuView)
        self.addSubview(ownerView)
        self.addSubview(uidOwnerView)
        self.addSubview(soonView)
        self.addSubview(idEventView)
        soonView.isHidden = true
        performConstraints()
    }
    
    func performConstraints() {
        mainImageView.leftAnchor.constraint(equalTo : self.safeAreaLayoutGuide.leftAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo : self.safeAreaLayoutGuide.topAnchor).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo : self.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mainImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        mainImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        soonView.rightAnchor.constraint(equalTo : self.rightAnchor).isActive = true
        soonView.leftAnchor.constraint(equalTo : self.mainImageView.rightAnchor, constant: 20).isActive = true
        soonView.topAnchor.constraint(equalTo : self.topAnchor, constant: 20).isActive = true
        soonView.bottomAnchor.constraint(equalTo: messageView.topAnchor).isActive = true
        
        messageView.rightAnchor.constraint(equalTo : self.rightAnchor).isActive = true
        messageView.leftAnchor.constraint(equalTo : self.mainImageView.rightAnchor, constant: 20).isActive = true
        messageView.topAnchor.constraint(equalTo : soonView.bottomAnchor, constant: 20).isActive = true
        
        dateView.rightAnchor.constraint(equalTo : self.rightAnchor).isActive = true
        dateView.leftAnchor.constraint(equalTo : self.mainImageView.rightAnchor, constant: 20).isActive = true
        dateView.topAnchor.constraint(equalTo: messageView.bottomAnchor).isActive = true
        
        lieuView.rightAnchor.constraint(equalTo : self.rightAnchor).isActive = true
        lieuView.leftAnchor.constraint(equalTo : self.mainImageView.rightAnchor, constant: 20).isActive = true
        lieuView.topAnchor.constraint(equalTo: dateView.bottomAnchor).isActive = true
        
        ownerView.rightAnchor.constraint(equalTo : self.safeAreaLayoutGuide.rightAnchor, constant: -15).isActive = true
        ownerView.topAnchor.constraint(equalTo : self.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        ownerView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        ownerView.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let message = nameEvent {
            messageView.text = message
        }
        if let image = mainImage {
            mainImageView.image = image
        }
        if let date = dateEvent {
            dateView.text = date
        }
        if let lieu = lieuEvent {
            lieuView.text = lieu
        }
        if let owner = ownerImg {
            ownerView.image = owner
        }
        if let uid = uidOwner {
            uidOwnerView.text = uid
        }
        if let soon = soonLabel {
            soonView.text = soon
        }
        if let idEv = idEvent {
            idEventView.text = idEv
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIFont {
    
    func withTraits(traits:UIFontDescriptor.SymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
    
    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }
    
    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
    
    func boldItalic() -> UIFont {
        return withTraits(traits: .traitBold, .traitItalic)
    }
    
}
