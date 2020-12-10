//
//  ShowCell.swift
//  LibX
//
//  Created by Lisa Fabien on 11/26/20.
//

import UIKit

class ShowCell: UITableViewCell {

    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    var checked : Bool?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        posterView.layer.cornerRadius = 12
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
