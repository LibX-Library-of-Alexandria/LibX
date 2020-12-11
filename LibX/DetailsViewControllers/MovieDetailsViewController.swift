//
//  MovieDetailsViewController.swift
//  LibX
//
//  Created by Lisa Fabien on 11/25/20.
//

import UIKit
import JJFloatingActionButton

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var movie : [String:Any]!
    var showAddButton : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDesign()
        
        //Floating action button
        if showAddButton {
            let actionButton = JJFloatingActionButton()

            actionButton.addItem(title: "Add Button", image: UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)) { item in
                self.performSegue(withIdentifier: "addSegue", sender: self)
            }
            actionButton.buttonColor = UIColor.systemTeal
            actionButton.display(inViewController: self)
            bottomConstraint.constant = 80
        } else {
            bottomConstraint.constant = 40
        }
    }
    
    func setDesign() {
        let title = movie["title"] as? String ?? "N/A"
        let synopsis = movie["overview"] as? String ?? "N/A"
        movieTitleLabel.text = title
        synopsisLabel.text = synopsis
        
        //Movie poster
        let baseUrl = "https://image.tmdb.org/t/p/w185"
        if let posterPath = movie["poster_path"] as? String {
            let posterUrl = URL(string: baseUrl + posterPath)
            posterImage.af_setImage(withURL: posterUrl!)
            //Shadow
            posterImage.layer.masksToBounds = false
            posterImage.layer.shadowColor = UIColor.black.cgColor
            posterImage.layer.shadowOffset = .zero
            posterImage.layer.shadowOpacity = 0.7
            posterImage.layer.shadowRadius = 10
            posterImage.layer.shadowPath = UIBezierPath(rect: posterImage.bounds).cgPath
        }
        
        //Backdrop image
        if let backdropPath = movie["backdrop_path"] as? String {
            let backdropUrl = URL(string: "https://image.tmdb.org/t/p/w780" + backdropPath)
            backgroundImage.af_setImage(withURL: backdropUrl!)
        }
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addViewController = segue.destination as! AddViewController
        //Lets view controller know what item to add to list
        addViewController.item = movie
        addViewController.type = "movie"
    }
}
