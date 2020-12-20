//
//  MovieCell.swift
//  LibX
//
//  Created by Lisa Fabien on 11/25/20.
//

import UIKit

class MovieCell: UITableViewCell {

    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var shadowView: UIView!
    var checked : Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        posterView.layer.cornerRadius = 12
        //posterView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        cardView.layer.cornerRadius = 12
        cardView.clipsToBounds = true
        
        //Add shadow to card
        shadowView.layer.cornerRadius = 12
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.25
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowRadius = 8
        shadowView.layer.shadowPath = UIBezierPath(rect: cardView.bounds).cgPath
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    

    }

}
