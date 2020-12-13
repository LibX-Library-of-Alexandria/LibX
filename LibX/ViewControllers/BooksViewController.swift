//
//  BooksViewController.swift
//  LibX
//
//  Created by Mina Kim on 11/24/20.
//

import UIKit
import AlamofireImage

class BooksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var books = [[String:Any]]()
    var numBooks = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //Removes lines in tableview
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor(named: "TableViewColor")
        //Bind refreshControl to action
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        //Bind control to tableView
        tableView.refreshControl = refreshControl
        
        //SearchBar setup
        searchBar.delegate = self
        searchBar.barTintColor = UIColor(named: "TableViewColor")
        searchBar.tintColor = UIColor.gray
        //Customize searchBar textfield
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.black
            textfield.backgroundColor = UIColor.white
            textfield.layer.cornerRadius = 18
            textfield.layer.masksToBounds = true
            textfield.placeholder = "Search for books"
        }
        //Remove searchBar border
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(named: "TableViewColor")?.cgColor
        
        //Removes text in back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //Change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "TableViewColor")
        self.navigationController?.navigationBar.tintColor = UIColor(named: "black_white") //Changes button color
        
        retrieveAPI() //Gets API info
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //Change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "TableViewColor")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell") as! BookCell
        
        let book = books[indexPath.row]
        let bookInfo = book["volumeInfo"] as! [String:Any]
        
        let title = bookInfo["title"] as? String ?? "N/A"
        let authors = bookInfo["authors"] as? [String] ?? ["N/A"]
        let author = authors[0]
        
        cell.bookTitleLabel.text = title
        cell.bookAuthorLabel.text = author
        
        //Set book cover
        if let imageLinks = bookInfo["imageLinks"] as? [String:Any] {
            let imageUrl = URL(string: imageLinks["thumbnail"] as! String)
            cell.bookImage.af_setImage(withURL: imageUrl!)
        }
        
        return cell
    }
    
    @objc private func refreshControlAction(_ refreshControl: UIRefreshControl) {
        retrieveAPI()
        refreshControl.endRefreshing()
    }
    
    func retrieveAPI(){
        print("Sending API")
        numBooks = 0
        
        //Send API request
        let apiKey = "AIzaSyA3ImZJPYLJB8lng-g7Rp4ibvPDUJN8dcU"
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=subject:fiction&printType=books&langRestrict=en&orderBy=newest&key=" + apiKey
        let url = URL(string: urlString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
              let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            //Sets books to books in API call
            let books = dataDictionary["items"] as! [[String:Any]]
            if books.count > 0{
                self.books = books
            } else { //No results
                let alert = UIAlertController(title: "No results", message: "Could not find results", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            
            //Updates app so that tableView isn't 0 (calls tableView funcs again)
            self.tableView.reloadData()
            
            print(dataDictionary)
           }
        }
        task.resume()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResultsAPI()
    }
    
    func searchResultsAPI(){
        print("Sending search")
        
        let input = searchBar.text
        var filteredInput = removeSpecialCharsFromString(text: input ?? "").lowercased() //Removes special chars & brings to lowercase
        filteredInput = filteredInput.trimmingCharacters(in: .whitespacesAndNewlines) //Removes beginning/trailing whitespace
        filteredInput = filteredInput.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil) //Replaces spaces w/ "+"
        
        let apiKey = "AIzaSyA3ImZJPYLJB8lng-g7Rp4ibvPDUJN8dcU"
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=" + filteredInput + "&printType=books&langRestrict=en&orderBy=relevance&key=" + apiKey
        let url = URL(string: urlString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription) //Alert user w/ UI
           } else if let data = data {
              let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            //Sets books to books in API call
            if let books = dataDictionary["items"] as? [[String:Any]] {
                self.books = books
                
                //Updates app so that tableView isn't 0 (calls tableView funcs again)
                self.tableView.reloadData()
                
                print(dataDictionary)
                print(filteredInput)
                print(self.books.count)
            } else { //Invalid user input
                let alert = UIAlertController(title: "Opps!", message: "Please check your spelling", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
           }
        }
        task.resume()
        searchBarCancelButtonClicked(searchBar)
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return String(text.filter {okayChars.contains($0) })
    }
    
    //Search bar cancel button
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
        self.searchBar.becomeFirstResponder()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == books.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                //Gets data
                self.loadMoreData()
            }
        }
    }
    func loadMoreData() {
        numBooks += 10
        
        //Send API request
        let apiKey = "AIzaSyA3ImZJPYLJB8lng-g7Rp4ibvPDUJN8dcU"
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=subject:fiction&printType=books&langRestrict=en&startIndex=" + String(numBooks) + "&orderBy=newest&key=" + apiKey
        let url = URL(string: urlString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
              let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            //Sets books to books in API call
            let books = dataDictionary["items"] as! [[String:Any]]
            if books.count > 0{
                //Adds book to books
                for book in books{
                    self.books.append(book)
                }
            } else { //No results
                let alert = UIAlertController(title: "No results", message: "Could not find results", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            
            //Updates app so that tableView isn't 0 (calls tableView funcs again)
            self.tableView.reloadData()
            
            print(dataDictionary)
           }
        }
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segueing to book details")
        
        //Gets selected cell
        let cell = sender as! BookCell
        let indexPath = tableView.indexPath(for: cell)!
        let book = books[indexPath.row]
        
        //Passes information to BooksDetailsViewController
        let booksDetailsViewController = segue.destination as! BooksDetailsViewController
        booksDetailsViewController.book = book
        booksDetailsViewController.showAddButton = true
        
        //De-highlights selected row
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
