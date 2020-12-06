//
//  MenuViewController.swift
//  LibX
//
//  Created by Aidan Furey on 11/22/20.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var categories : [[String:Any]] = [
         ["title": "Movies", "image": ""],
         ["title": "TV Shows", "image": ""],
         ["title": "Books", "image": ""],
         ["title": "Songs", "image": ""]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //Removes text in back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
        
        let cat = categories[indexPath.row]
        
        let title = cat["title"] as! String
        //let image = UIImage(cat["image"])
        
        cell.categoryLabel.text = title
        
        return cell
    }
    
    //Sends user to respective database based on selected cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if (categories[indexPath.row]["title"] as! String == "Movies"){
            performSegue(withIdentifier: "MoviesViewController",
                         sender: MenuCell.self)
        } else if (categories[indexPath.row]["title"] as! String == "TV Shows"){
            performSegue(withIdentifier: "ShowsViewController",
                         sender: MenuCell.self)
        } else if (categories[indexPath.row]["title"] as! String == "Books"){
            performSegue(withIdentifier: "BooksViewController",
                         sender: MenuCell.self)
        } else {
            performSegue(withIdentifier: "SongsViewController",
                         sender: MenuCell.self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        print("Seguing to different database")
    }

}
