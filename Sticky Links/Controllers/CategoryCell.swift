//
//  CategoryCell.swift
//  Sticky Links
//
//  Created by Keval Vadoliya on 02/11/21.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var bookmarkButton: UIButton!
    var bookmarkAction: ((UIButton) -> Void)?
    
    func configureWithModel(category: Category) {
        textLabel?.text = category.name
        let image = category.isFavourite ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
        bookmarkButton.setImage(image, for: .normal)
    }
    
    @IBAction func bookmarkButtonAction(_ sender: UIButton) {
        bookmarkAction?(sender)
    }

}
