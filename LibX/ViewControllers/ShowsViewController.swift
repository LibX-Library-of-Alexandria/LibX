//
//  ShowsViewController.swift
//  LibX
//
//  Created by Mina Kim on 11/24/20.
//

import UIKit
import AlamofireImage

class ShowsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var shows = [[String:Any]]()
    var page : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        retrieveAPI() //Moved code to new function
        
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
            textfield.placeholder = "Search for TV Shows"
        }
        //Remove searchBar border
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(named: "TableViewColor")?.cgColor
        searchBar.autocorrectionType = .yes
        
        //Removes text in back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //Change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "TableViewColor")
        self.navigationController?.navigationBar.tintColor = UIColor(named: "black_white") //Changes button color
    }
    
    func retrieveAPI() {
        page = 1
        // Do any additional setup after loading the view.
        let url = URL(string: "https://api.themoviedb.org/3/tv/popular?api_key=81eb8300739b19966e28c34a105320d0&language=en-US&page=1")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
           // This will run when the network request returns
           if let error = error {
              print(error.localizedDescription)
           } else if let data = data {
              let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            let shows = dataDictionary["results"] as! [[String:Any]]
            if shows.count > 0{
                self.shows = shows
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
        
        let apiKey = "81eb8300739b19966e28c34a105320d0"
        let urlString = "https://api.themoviedb.org/3/search/tv?api_key=" + apiKey + "&page=1&query=" + filteredInput + "&include_adult=false"
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
            
            if let shows = dataDictionary["results"] as? [[String:Any]] {
                self.shows = shows
                
                //Updates app so that tableView isn't 0 (calls tableView funcs again)
                self.tableView.reloadData()
                
                //print(dataDictionary)
                //print(filteredInput)
                //print(self.shows.count)
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
        return shows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowCell") as! ShowCell
        
        let show = shows[indexPath.row]
        let title = show["name"] as! String
        let synopsis = show["overview"] as! String
        
        cell.titleLabel!.text = title
        cell.synopsisLabel.text = synopsis
        
        //Set poster image (check if image exists)
        let baseUrl = "https://image.tmdb.org/t/p/w185"
        if let posterPath = show["poster_path"] as? String {
            let posterUrl = URL(string: baseUrl + posterPath)!
            cell.posterView.af.setImage(withURL: posterUrl)
        }

        return cell
    }
    
    //Loads more data when screen reaches last row
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == shows.count{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                //Gets data
                self.loadMoreData()
            }
        }
    }

    func loadMoreData(){
        page += 1
        let urlString = "https://api.themoviedb.org/3/tv/popular?api_key=81eb8300739b19966e28c34a105320d0&language=en-US&page=" + String(page)
        
        // Create the URLRequest 'request'
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

            //Use the new data to update the data source
            print(dataDictionary)
            let shows = dataDictionary["results"] as! [[String:Any]]
            //Adds movies to movies
            for show in shows{
                self.shows.append(show)
            }
            
            //Updates tableView
            self.tableView.reloadData()

            print(dataDictionary)
           }
        }
        task.resume()
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segueing to show details")
        
        //Gets selected cell
        let cell = sender as! ShowCell
        let indexPath = tableView.indexPath(for: cell)!
        let show = shows[indexPath.row]
        
        //Passes information to BooksDetailsViewController
        let showDetailsViewController = segue.destination as! ShowDetailsViewController
        showDetailsViewController.show = show
        showDetailsViewController.showAddButton = true
        
        //De-highlights selected row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}
