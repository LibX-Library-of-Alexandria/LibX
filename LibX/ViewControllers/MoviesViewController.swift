//
//  MoviesViewController.swift
//  LibX
//
//  Created by Mina Kim on 11/24/20.
//

import UIKit
import AlamofireImage

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        retrieveAPI()
        
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
            textfield.placeholder = "Search for Movies"
        }
        //Remove searchBar border
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(named: "TableViewColor")?.cgColor
        
        //Removes text in back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //Change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "TableViewColor")
    }
    
    func retrieveAPI() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
              let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            let movies = dataDictionary["results"] as! [[String:Any]]
            if movies.count > 0 {
                self.movies = movies
            } else { //No results
                let alert = UIAlertController(title: "No results", message: "Could not find results", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            self.tableView.reloadData()
            
            print(dataDictionary)

           }
        }
        task.resume()
    }
    
    @objc private func refreshControlAction(_ refreshControl: UIRefreshControl) {
        retrieveAPI()
        refreshControl.endRefreshing()
    }
    
    //Search functions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchResultsAPI()
    }
    func searchResultsAPI() {
        print("Sending search")
        
        //Parse user's input text
        let input = searchBar.text
        var filteredInput = removeSpecialCharsFromString(text: input ?? "").lowercased() //Removes special chars & brings to lowercase
        filteredInput = filteredInput.trimmingCharacters(in: .whitespacesAndNewlines) //Removes beginning/trailing whitespace
        filteredInput = filteredInput.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil) //Replaces spaces w/ "%20"
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let urlString = "https://api.themoviedb.org/3/search/movie?api_key=" + apiKey + "&page=1&query=" + filteredInput + "&include_adult=false"
        print(urlString)
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
            if let movies = dataDictionary["results"] as? [[String:Any]] {
                self.movies = movies
                
                //Updates app so that tableView isn't 0 (calls tableView funcs again)
                self.tableView.reloadData()
                
                print(dataDictionary)
                print(filteredInput)
                print(self.movies.count)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell

        
        let movie = movies[indexPath.row]
        let title = movie["title"] as? String ?? "N/A"
        let synopsis = movie["overview"] as? String ?? "N/A"
        
        cell.titleLabel!.text = title
        cell.synopsisLabel.text = synopsis
        
        let baseUrl = "https://image.tmdb.org/t/p/w185"
        if let posterPath = movie["poster_path"] as? String {
            let posterUrl = URL(string: baseUrl + posterPath)!
            cell.posterView.af.setImage(withURL: posterUrl)
        }
        
        return cell
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segueing to movie details")
        
        //Gets selected cell
        let cell = sender as! MovieCell
        let indexPath = tableView.indexPath(for: cell)!
        let movie = movies[indexPath.row]
        
        //Passes information to BooksDetailsViewController
        let movieDetailsViewController = segue.destination as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
        movieDetailsViewController.showAddButton = true
        
        //De-highlights selected row
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
