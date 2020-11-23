//
//  MenuViewController.swift
//  LibX
//
//  Created by Aidan Furey on 11/22/20.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableview: UITableView!
    
    var categories : [[String:Any]] = [
         ["title": "Movies", "image": ""],
         ["title": "TV Shows", "image": ""],
         ["title": "Books", "image": ""],
         ["title": "Songs", "image": ""]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableview.delegate = self
        self.tableview.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell
        
        let cat = categories[indexPath.row]
        
        let title = cat["title"] as! String
        //let image = UIImage(cat["image"])
        
        cell.categoryLabel.text = title
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
