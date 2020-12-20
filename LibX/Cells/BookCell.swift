//
//  BookCell.swift
//  LibX
//
//  Created by Mina Kim on 11/24/20.
//

import UIKit

class BookCell: UITableViewCell {

    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var shadowView: UIView!
    var checked : Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bookImage.layer.cornerRadius = 12
        //bookImage.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        cardView.layer.cornerRadius = 12
        cardView.clipsToBounds = true
        
        //Add shadow to card
        shadowView.layer.cornerRadius = 12
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.25
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowRadius = 8
        shadowView.layer.shadowPath = UIBezierPath(rect: shadowView.bounds).cgPath
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
