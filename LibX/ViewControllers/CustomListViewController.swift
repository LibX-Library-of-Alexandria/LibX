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
        //if items.count > 0{
            return items.count
        //} else { return 1 }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //if items.count > 0 {
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
                cell.scrollView.layer.cornerRadius = 12
                cell.shadowView.layer.cornerRadius = 12
                cell.cardView.layer.cornerRadius = 0
                cell.cardView.layer.shadowOpacity = 0
                //Add shadow to card
                cell.shadowView.layer.shadowColor = UIColor.black.cgColor
                cell.shadowView.layer.shadowOpacity = 0.25
                cell.shadowView.layer.shadowOffset = .zero
                cell.shadowView.layer.shadowRadius = 8
                cell.shadowView.layer.shadowPath = UIBezierPath(rect: cell.shadowView.bounds).cgPath
                
                cell.scrollView.showsHorizontalScrollIndicator = false
                cell.scrollView.delegate = self
                cell.scrollView.tag = indexPath.row //Associates scrollView with specific cell
                cell.cardView.tag = indexPath.row
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
                
                cell.scrollView.layer.cornerRadius = 12
                cell.shadowView.layer.cornerRadius = 12
                cell.cardView.layer.cornerRadius = 0
                cell.cardView.layer.shadowOpacity = 0
                //Add shadow to card
                cell.shadowView.layer.shadowColor = UIColor.black.cgColor
                cell.shadowView.layer.shadowOpacity = 0.25
                cell.shadowView.layer.shadowOffset = .zero
                cell.shadowView.layer.shadowRadius = 8
                cell.shadowView.layer.shadowPath = UIBezierPath(rect: cell.shadowView.bounds).cgPath
                
                cell.scrollView.showsHorizontalScrollIndicator = false
                cell.scrollView.delegate = self
                cell.scrollView.tag = indexPath.row //Associates scrollView with specific cell
                cell.cardView.tag = indexPath.row
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
                
                cell.scrollView.layer.cornerRadius = 12
                cell.shadowView.layer.cornerRadius = 12
                cell.cardView.layer.cornerRadius = 0
                cell.cardView.layer.shadowOpacity = 0
                //Add shadow to card
                cell.shadowView.layer.shadowColor = UIColor.black.cgColor
                cell.shadowView.layer.shadowOpacity = 0.25
                cell.shadowView.layer.shadowOffset = .zero
                cell.shadowView.layer.shadowRadius = 8
                cell.shadowView.layer.shadowPath = UIBezierPath(rect: cell.shadowView.bounds).cgPath
                
                cell.scrollView.showsHorizontalScrollIndicator = false
                cell.scrollView.delegate = self
                cell.scrollView.tag = indexPath.row //Associates scrollView with specific cell
                cell.cardView.tag = indexPath.row
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                cell.cardView.addGestureRecognizer(tap)
                
                return cell
            }
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")!
//            return cell
//        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let rowNum = (sender as! UITapGestureRecognizer).view?.tag
        if let cell = tableView.visibleCells[rowNum!] as? BookCell {
            performSegue(withIdentifier: "bookDetails", sender: cell)
        } else if let cell = tableView.visibleCells[rowNum!] as? MovieCell {
            performSegue(withIdentifier: "movieDetails", sender: cell)
        } else if let cell = tableView.visibleCells[rowNum!] as? ShowCell {
            performSegue(withIdentifier: "showDetails", sender: cell)
        }
    }
    
    //Delete cell/item
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        if offset >= scrollView.frame.size.width-10 {
            print("Did scroll all the way")
            let rowNum = scrollView.tag
            let item = items[(items.count-1)-rowNum]
            items.remove(at: rowNum)
            tableView.deleteRows(at: [[0,rowNum]], with: .fade)
            item.deleteInBackground { (success, error) in
                if success {
                    self.retrieveItems()
                } else {
                    print("Error in deleting item: \(error)")
                }
            }
        }
    }
    
    // this method handles checking cells
    // Not working
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var image = UIImage(named: "checkmark")
        let string = NSLocalizedString("Check", comment: "Check")
        if let cell = tableView.cellForRow(at: indexPath) as? BookCell {
            if (cell.checked) != nil {
                if cell.checked! {
                    cell.checked = false
                    image = UIImage(named: "arrowshape.turn.up.left")
                } else {
                    cell.checked = true
                }
            } else { cell.checked = true }
            let action = UIContextualAction(style: .normal, title: string,
                handler: { (action, view, completionHandler) in
                // Update data source when user taps action
                    if cell.checked! {
                        cell.cardView.layer.opacity = 1
                    } else { cell.cardView.layer.opacity = 0.2 }
                completionHandler(true)
            })
            action.backgroundColor = UIColor(named: "pale_spring_bud")
            action.image = image
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
            
        } else if let cell = tableView.cellForRow(at: indexPath) as? MovieCell {
            if (cell.checked) != nil {
                if cell.checked! {
                    cell.checked = false
                    image = UIImage(named: "arrowshape.turn.up.left")
                } else {
                    cell.checked = true
                }
            } else { cell.checked = true }
            let action = UIContextualAction(style: .normal, title: string,
                handler: { (action, view, completionHandler) in
                // Update data source when user taps action
                    if cell.checked! {
                        cell.cardView.layer.opacity = 1
                    } else { cell.cardView.layer.opacity = 0.2 }
                completionHandler(true)
            })
            action.backgroundColor = UIColor(named: "pale_spring_bud")
            action.image = image
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
            
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! ShowCell
            if (cell.checked) != nil {
                if cell.checked! {
                    cell.checked = false
                    image = UIImage(named: "arrowshape.turn.up.left")
                } else {
                    cell.checked = true
                }
            } else { cell.checked = true }
            let action = UIContextualAction(style: .normal, title: string,
                handler: { (action, view, completionHandler) in
                // Update data source when user taps action
                    if cell.checked! {
                        cell.cardView.layer.opacity = 1
                    } else { cell.cardView.layer.opacity = 0.2 }
                completionHandler(true)
            })
            action.backgroundColor = UIColor(named: "pale_spring_bud")
            action.image = image
            let configuration = UISwipeActionsConfiguration(actions: [action])
            return configuration
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Gets selected cell
        print("segue")
        if let cell = sender as? BookCell {
//            let rowNum = bookTGR.view?.tag
//            let cell = tableView.visibleCells[rowNum!]
            let indexPath = tableView.indexPath(for: cell)!
            let item = items[(items.count-1)-indexPath.row]
            let book = item["details"] as! [String:Any]
            print(book)

            //Passes information to BooksDetailsViewController
            let booksDetailsViewController = segue.destination as! BooksDetailsViewController
            booksDetailsViewController.book = book
            booksDetailsViewController.showAddButton = false
            print("book")
            
            //De-highlights selected row
            //tableView.deselectRow(at: indexPath, animated: true)
        } else if let cell = sender as? MovieCell {
            //let cell = sender as! MovieCell
            let indexPath = tableView.indexPath(for: cell)!
            let item = items[(items.count-1)-indexPath.row]
            let movie = item["details"] as! [String:Any]
            print(movie)
            
            //Passes information to MovieDetailsViewController
            let movieDetailsViewController = segue.destination as! MovieDetailsViewController
            movieDetailsViewController.movie = movie
            movieDetailsViewController.showAddButton = false
            
            //De-highlights selected row
            tableView.deselectRow(at: indexPath, animated: true)
        } else if let cell = sender as? ShowCell {
            //let cell = sender as! ShowCell
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
