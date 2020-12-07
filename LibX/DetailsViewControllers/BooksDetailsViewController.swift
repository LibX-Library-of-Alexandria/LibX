//
//  BooksDetailsViewController.swift
//  LibX
//
//  Created by Mina Kim on 11/28/20.
//

import UIKit
import AlamofireImage
import JJFloatingActionButton

class BooksDetailsViewController: UIViewController {

    @IBOutlet weak var bookImage: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var bookAuthorLabel: UILabel!
    @IBOutlet weak var bookPubDateLabel: UILabel!
    @IBOutlet weak var bookSynopsisLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    var book : [String:Any]!
    var showAddButton : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bookInfo = book["volumeInfo"] as! [String:Any]
        print(bookInfo["title"])
        bookAuthorLabel.text = ""
        
        bookTitleLabel.text = bookInfo["title"] as! String
        let authors = bookInfo["authors"] as! [String]
        //Shows all authors of book
        for author in authors {
            bookAuthorLabel.text! += author + "+"
        }
        bookAuthorLabel.text = bookAuthorLabel.text?.dropLast().replacingOccurrences(of: "+", with: ", ")
        //Check if exists
        bookPubDateLabel.text = (bookInfo["publisher"] as? String ?? "N/A") + ", " + (bookInfo["publishedDate"] as? String ?? "N/A")
        
        //Set book cover
        if let imageLinks = bookInfo["imageLinks"] as? [String:Any] {
            let imageUrl = URL(string: imageLinks["thumbnail"] as! String)
            bookImage.af_setImage(withURL: imageUrl!)
        }
        
        //Remove special characters before
        bookSynopsisLabel.text = bookInfo["description"] as? String ?? "N/A"

        bookImage.layer.masksToBounds = false
        bookImage.layer.shadowColor = UIColor.black.cgColor
        bookImage.layer.shadowOffset = .zero
        bookImage.layer.shadowOpacity = 0.4
        bookImage.layer.shadowRadius = 8
        bookImage.layer.shadowPath = UIBezierPath(rect: bookImage.bounds).cgPath
        
//        let contentRect: CGRect = scrollView.subviews.reduce(into: .zero) { rect, view in
//            rect = rect.union(view.frame)
//        }
//        scrollView.contentSize = contentRect.size
        
        //Floating action button
        if showAddButton {
            let actionButton = JJFloatingActionButton()

            actionButton.addItem(title: "Add Button", image: UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)) { item in
                self.performSegue(withIdentifier: "addSegue", sender: self)
            }
            actionButton.buttonColor = UIColor.systemTeal
            actionButton.display(inViewController: self)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let addViewController = segue.destination as! AddViewController
        addViewController.item = book
    }
    

}
