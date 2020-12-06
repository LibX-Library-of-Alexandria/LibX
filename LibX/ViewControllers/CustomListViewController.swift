//
//  CustomListViewController.swift
//  LibX
//
//  Created by Mina Kim on 12/6/20.
//

import UIKit
import Parse

class CustomListViewController: UIViewController {//}, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var listTitleLabel: UILabel!
    
    var items = [PFObject]()
    var list : PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                //self.tableView.reloadData()
            } else {
                print("Could not find items: \(error)")
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
//
//        return cell
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
