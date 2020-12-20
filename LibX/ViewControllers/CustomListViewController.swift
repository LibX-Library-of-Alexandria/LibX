//
//  CustomListViewController.swift
//  LibX
//
//  Created by Mina Kim on 12/6/20.
//

import UIKit
import Parse

class CustomListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listTitleLabel: UILabel!
    
    var items = [PFObject]()
    var list : PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tag = -1 //Differentiation for scroll
        
        retrieveItems()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        //Bind refreshControl to action
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        //Bind control to tableView
        tableView.refreshControl = refreshControl
        
        listTitleLabel.text = list["title"] as? String
        
        //Removes text in back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //Change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "powder_blue")
        self.navigationController?.navigationBar.tintColor = UIColor(named: "black_white") //Changes button color
    }
    
    func retrieveItems(){
        let query = PFQuery(className: "Items").whereKey("list", equalTo: list!)
        query.includeKey("details")
        
        query.findObjectsInBackground { (items, error) in
            if items != nil {
                self.items = items!
                //print(self.items.count)
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
            //Shows main contents of cell when tableview loads
            DispatchQueue.main.async {
                let width = cell.scrollView.frame.size.width
                cell.scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
            }
            cell.scrollView.layer.cornerRadius = 12
            cell.cardView.layer.cornerRadius = 0
            cell.cardView.layer.shadowOpacity = 0
            //Check if card is checked
            if (item["checked"] as? Bool ?? false) {
                cell.cardView.layer.opacity = 0.2
            }
            //Set horizontal scroll features
            cell.scrollView.showsHorizontalScrollIndicator = false
            cell.scrollView.delegate = self
            cell.scrollView.tag = indexPath.row //Associates scrollView with specific cell
            cell.cardView.tag = indexPath.row //Associates cardView with specific cell
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            cell.cardView.addGestureRecognizer(tap)
            
            return cell
        } else if type == "movie" {
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
            
            //Shows main contents of cell when tableview loads
            DispatchQueue.main.async {
                let width = cell.scrollView.frame.size.width
                cell.scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
            }
            cell.scrollView.layer.cornerRadius = 12
            cell.cardView.layer.cornerRadius = 0
            cell.cardView.layer.shadowOpacity = 0
            //Check if card is checked
            if (item["checked"] as? Bool ?? false) {
                cell.cardView.layer.opacity = 0.2
            }
            cell.scrollView.showsHorizontalScrollIndicator = false
            cell.scrollView.delegate = self
            cell.scrollView.tag = indexPath.row //Associates scrollView with specific cell
            cell.cardView.tag = indexPath.row //Associates cardView with specific cell
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            cell.cardView.addGestureRecognizer(tap)
            
            return cell
        } else {
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
            
            //Shows main contents of cell when tableview loads
            DispatchQueue.main.async {
                let width = cell.scrollView.frame.size.width
                cell.scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
            }
            cell.scrollView.layer.cornerRadius = 12
            cell.cardView.layer.cornerRadius = 0
            cell.cardView.layer.shadowOpacity = 0
            //Check if card is checked
            if (item["checked"] as? Bool ?? false) {
                cell.cardView.layer.opacity = 0.2
            }
            //Set horizontal scroll features
            cell.scrollView.showsHorizontalScrollIndicator = false
            cell.scrollView.delegate = self
            cell.scrollView.tag = indexPath.row //Associates scrollView with specific cell
            cell.cardView.tag = indexPath.row //Associates cardView with specific cell
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            cell.cardView.addGestureRecognizer(tap)
            
            return cell
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let rowNum = (sender as! UITapGestureRecognizer).view?.tag
        //let cell = tableView.cellForRow(at: [0,rowNum!])
        if let cell = tableView.cellForRow(at: [0,rowNum!]) as? BookCell {
            performSegue(withIdentifier: "bookDetails", sender: cell)
        } else if let cell = tableView.cellForRow(at: [0,rowNum!]) as? MovieCell {
            performSegue(withIdentifier: "movieDetails", sender: cell)
        } else if let cell = tableView.cellForRow(at: [0,rowNum!]) as? ShowCell {
            performSegue(withIdentifier: "showDetails", sender: cell)
        }
    }
    
    //Delete cell/item
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.tag != -1 {
            let offset = scrollView.contentOffset.x
            let width = scrollView.frame.size.width
            if offset >= width*2 {
                let rowNum = scrollView.tag
                let item = items[(items.count-1)-rowNum]
                //print(item)
                items.remove(at: rowNum)
                tableView.deleteRows(at: [[0,rowNum]], with: .fade)
                item.deleteInBackground { (success, error) in
                    if !success {
                        print("Error in deleting item: \(error)")
                    }
                }
            } else if offset == 0 {
                let rowNum = scrollView.tag
                checkItem(rowNum: rowNum)
                scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: true)
            }
        } else {
            print("TableView")
        }
    }
    
    func checkItem(rowNum: Int) {
        let item = items[(items.count-1)-rowNum]
        if (item["checked"] as? Bool ?? false) {
            item["checked"] = false
            fadeCell(rowNum: rowNum, opacity: 1)
            item.saveInBackground()
        } else {
            item["checked"] = true
            fadeCell(rowNum: rowNum, opacity: 0.2)
            item.saveInBackground()
        }
    }
    //Check cell type and change cell's cardView opacity
    func fadeCell(rowNum: Int, opacity: Float) {
        if let cell = tableView.cellForRow(at: [0,rowNum]) as? BookCell {
            cell.cardView.layer.opacity = opacity
        } else if let cell = tableView.cellForRow(at: [0,rowNum]) as? MovieCell {
            cell.cardView.layer.opacity = opacity
        } else if let cell = tableView.cellForRow(at: [0,rowNum]) as? ShowCell {
            cell.cardView.layer.opacity = opacity
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Gets selected cell
        print("segue")
        if let cell = sender as? BookCell {
            let indexPath = tableView.indexPath(for: cell)!
            let item = items[(items.count-1)-indexPath.row]
            let book = item["details"] as! [String:Any]

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
            
            //Passes information to MovieDetailsViewController
            let movieDetailsViewController = segue.destination as! MovieDetailsViewController
            movieDetailsViewController.movie = movie
            movieDetailsViewController.showAddButton = false
            
            //De-highlights selected row
            tableView.deselectRow(at: indexPath, animated: true)
        } else if let cell = sender as? ShowCell {
            let indexPath = tableView.indexPath(for: cell)!
            let item = items[(items.count-1)-indexPath.row]
            let show = item["details"] as! [String:Any]
            
            //Passes information to ShowDetailsViewController
            let showDetailsViewController = segue.destination as! ShowDetailsViewController
            showDetailsViewController.show = show
            showDetailsViewController.showAddButton = false
            
            //De-highlights selected row
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
