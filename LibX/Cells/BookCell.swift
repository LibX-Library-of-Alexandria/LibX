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
        cardView.layer.cornerRadius = 12
        //cardView.layer.masksToBounds = true
        
        //Add shadow to card
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.25
        cardView.layer.shadowOffset = .zero
        cardView.layer.shadowRadius = 8
        cardView.layer.shadowPath = UIBezierPath(rect: cardView.bounds).cgPath

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
