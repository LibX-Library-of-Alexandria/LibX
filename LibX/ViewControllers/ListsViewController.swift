//
//  ListsViewController.swift
//  Pods
//
//  Created by Mina Kim on 11/23/20.
//

import UIKit
import Parse

class ListsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var lists = [PFObject]()
    //var selectedList : PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        //Space betwwen "rows"
        layout.minimumLineSpacing = 0
        //Space between items in "rows"
        layout.minimumInteritemSpacing = 0
        
        //Width of phone / 2
        let width = (collectionView.frame.size.width - layout.minimumInteritemSpacing * 2) * (1/2)
        //Size of each item in collection view
        layout.itemSize = CGSize(width: width, height: width)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        retrieveLists()
    }
    
    func retrieveLists() {
        print("Retrieving lists")
        
        let query = PFQuery(className: "Lists")
        query.includeKeys(["title", "user", "photo"])
        //query.limit?
        
        query.findObjectsInBackground { (lists, error) in
            if lists != nil{
                self.lists = lists!
                self.collectionView.reloadData()
            } else {
                print("Could not find lists: \(error)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lists.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < lists.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! ListCell
            let list = lists[(lists.count-1)-indexPath.row]
            
            cell.listImage.layer.cornerRadius = 20
            cell.listImage.layer.masksToBounds = true
            cell.containerView.layer.cornerRadius = 20
            cell.containerView.layer.masksToBounds = true
            
            cell.listTitleLabel.text = list["title"] as! String
            cell.containerView.alpha = 0.5
            
            cell.editListButton.alpha = 0.5
            
            print(indexPath.row)
            
            return cell
        } else { //Last cell in collectionView
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlusCell", for: indexPath) as! PlusCell
            
            print("PlusCell")
            
            cell.plusImage.alpha = 0.2
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ListCell {
            print("Clicked ListCell")
        } else {
            print("Clicked PlusCell")
            let alert = UIAlertController(title: "Creating Custom List", message: "Enter list title", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "List Title"
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                if let input = alert?.textFields?.first?.text {
                    print("Input: \(input)")
                    
                    //POST to Parse
                    let list = PFObject(className: "Lists")
                    
                    list["title"] = input
                    list["user"] = PFUser.current()
                    list["photo"] = ""
                    
                    list.saveInBackground { (success, error) in
                        if success {
                            print("Successfully saved list \(input)")
                        } else {
                            print("Could not save list")
                        }
                    }
                    self.retrieveLists()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func editList(_ sender: Any) {
        print("Edit list")
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
