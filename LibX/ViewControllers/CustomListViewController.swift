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
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        //Bind refreshControl to action
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        //Bind control to tableView
        tableView.refreshControl = refreshControl
        
        listTitleLabel.text = list["title"] as? String
        //Change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "powder_blue")
        
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
    
    @objc private func refreshControlAction(_ refreshControl: UIRefreshControl) {
        retrieveItems()
        refreshControl.endRefreshing()
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
            let movie = item["details"] as! [String:Any]
            
            let title = movie["title"] as? String ?? "N/A"
            let synopsis = movie["overview"] as? String ?? "N/A"
            
            cell.titleLabel!.text = title
            cell.synopsisLabel.text = synopsis
            
            let baseUrl = "https://image.tmdb.org/t/p/w185"
            let posterPath = movie["poster_path"] as! String
            let posterUrl = URL(string: baseUrl + posterPath)!
            
            cell.posterView.af.setImage(withURL: posterUrl)
            
            return cell
        } else {
            print("ShowCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "ShowCell", for: indexPath) as! ShowCell
            let show = item["details"] as! [String:Any]
            
            let title = show["name"] as? String ?? "N/A"
            let synopsis = show["overview"] as? String ?? "N/A"
            
            cell.titleLabel!.text = title
            cell.synopsisLabel.text = synopsis
            
            let baseUrl = "https://image.tmdb.org/t/p/w185"
            let posterPath = show["poster_path"] as! String
            let posterUrl = URL(string: baseUrl + posterPath)!
            
            cell.posterView.af.setImage(withURL: posterUrl)
            
            return cell
        }
    }
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // remove the item from the data model
            let item = items[(items.count-1)-indexPath.row]
            items.remove(at: indexPath.row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            item.deleteInBackground { (success, error) in
                if success {
                    self.retrieveItems()
                } else {
                    print("Error in deleting item: \(error)")
                }
            }
        } else if editingStyle == .insert {
            //Insert row?
            print("Insert editing style")
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
            let movie = item["details"] as! [String:Any]
            print(movie)
            
            //Passes information to MovieDetailsViewController
            let movieDetailsViewController = segue.destination as! MovieDetailsViewController
            //movieDetailsViewController.show = show
            //movieDetailsViewController.showAddButton = false
            
            //De-highlights selected row
            tableView.deselectRow(at: indexPath, animated: true)
        } else if let cell = sender as? ShowCell {
            let indexPath = tableView.indexPath(for: cell)!
            let item = items[(items.count-1)-indexPath.row]
            let show = item["details"] as! [String:Any]
            print(show)
            
            //Passes information to ShowDetailsViewController
            let showDetailsViewController = segue.destination as! ShowDetailsViewController
            showDetailsViewController.show = show
            showDetailsViewController.showAddButton = false
            
            //De-highlights selected row
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
