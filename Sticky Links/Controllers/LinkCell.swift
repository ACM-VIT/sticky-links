//
//  LinkCell.swift
//  Sticky Links
//
//  Created by Keval Vadoliya on 02/11/21.
//

import UIKit

class LinkCell: UITableViewCell {

    @IBOutlet weak var bookmarkButton: UIButton!
    var bookmarkAction: ((UIButton) -> Void)?
    
    func configureWithModel(link: Items) {
        textLabel?.text = link.title
        let image = link.isFavourite ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        bookmarkButton.setImage(image, for: .normal)
    }
    
    @IBAction func bookmarkButtonAction(_ sender: UIButton) {
        bookmarkAction?(sender)
    }

}
