//
//  CustomListViewController.swift
//  LibX
//
//  Created by Mina Kim on 12/6/20.
//

import UIKit
import Parse

class CustomListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listTitleLabel: UILabel!
    
    var items = [PFObject]()
    var list : PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        listTitleLabel.text = list["title"] as? String
        //Change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "opal")

        retrieveItems()
    }
    
    func retrieveItems(){
        let query = PFQuery(className: "Items").whereKey("list", equalTo: list!)
        query.includeKey("details")
        
        query.findObjectsInBackground { (items, error) in
            if items != nil {
                print("Found items")
                self.items = items!
                print(self.items.count)
                self.tableView.reloadData()
            } else {
                print("Could not find items: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[(items.count-1)-indexPath.row]
        let type = item["type"] as! String
        
        if type == "book" {
            print("BookCell")

            let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookCell
            let book = item["details"] as! [String:Any]
            let bookInfo = book["volumeInfo"] as! [String:Any]
            
            let title = bookInfo["title"] as! String
            let authors = bookInfo["authors"] as! [String]
            let author = authors[0]
            
            cell.bookTitleLabel.text = title
            cell.bookAuthorLabel.text = author
            
            //Set book cover
            if let imageLinks = bookInfo["imageLinks"] as? [String:Any] {
                let imageUrl = URL(string: imageLinks["thumbnail"] as! String)
                cell.bookImage.af_setImage(withURL: imageUrl!)
            }
            
            return cell
        } else if type == "movie" {
            print("MovieCell")

            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
            
            //Code later
            
            return cell
        } else {
            print("ShowCell")

            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowCell", for: indexPath) as! ShowCell
            
            //Code later
            
            return cell
        }
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Gets selected cell
        if let cell = sender as? BookCell {
            let indexPath = tableView.indexPath(for: cell)!
            let item = items[(items.count-1)-indexPath.row]
            let book = item["details"] as! [String:Any]
            print(book)
            
            //Passes information to BooksDetailsViewController
            let booksDetailsViewController = segue.destination as! BooksDetailsViewController
            booksDetailsViewController.book = book
            booksDetailsViewController.showAddButton = false
            
            //De-highlights selected row
            tableView.deselectRow(at: indexPath, animated: true)
        } else if let cell = sender as? MovieCell {
            let indexPath = tableView.indexPath(for: cell)!
            let item = items[(items.count-1)-indexPath.row]
            
            //De-highlights selected row
            tableView.deselectRow(at: indexPath, animated: true)
        } else if let cell = sender as? ShowCell {
            let indexPath = tableView.indexPath(for: cell)!
            let item = items[(items.count-1)-indexPath.row]
            
            //De-highlights selected row
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
