//
//  AddViewController.swift
//  LibX
//
//  Created by Mina Kim on 12/5/20.
//

import UIKit
import Parse

class AddViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var lists = [PFObject]()
    var selectedList : PFObject!
    var item : [String:Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        //Space betwwen "rows"
        layout.minimumLineSpacing = 0
        //Space between items in "rows"
        layout.minimumInteritemSpacing = 0
        
        //Width of collectionview / 2
        let width = (self.view.frame.size.width - 20) * (1/2)
        //Size of each item in collection view
        layout.itemSize = CGSize(width: width, height: width)
        
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
        return lists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddToListCell", for: indexPath) as! AddToListCell
        let list = lists[(lists.count-1)-indexPath.row]
        
        cell.listImage.layer.cornerRadius = 20
        cell.listImage.layer.masksToBounds = true
        cell.containerView.layer.cornerRadius = 20
        cell.containerView.layer.masksToBounds = true

        cell.listTitleLabel.text = list["title"] as! String
        cell.containerView.alpha = 0.5
        cell.listTitleLabel.alpha = 1
        
        if let imageFile = list["photo"] as? PFFileObject { //Checks if list has photo
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.listImage.af_setImage(withURL: url)
        }
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let list = lists[(lists.count-1)-indexPath.row]
        let newItem = PFObject(className: "Items")
        var id : String!
        
        //Checks type of id (String or Int)
        if ((item["id"] as? Int) != nil) {
            id = String(item["id"] as! Int)
        } else {
            id = item["id"] as! String
        }
        
        newItem["itemId"] = id ?? "nil" //newItem["objectId"] = item["id"] as? String
        newItem["details"] = item //Convert to JSON?
        newItem["list"] = list //Pointer to list object
        newItem["type"] = "book"
        
        //Check if item already points to list
        let query = PFQuery(className: "Items").whereKey("list", equalTo: list).whereKey("itemId", equalTo: id!)
        query.findObjectsInBackground { (objects, error) in
            if objects != nil {
                if objects!.count == 0 {
                    //POST item & creates association w/ list
                    newItem.saveInBackground { (success, error) in
                        if success{
                            //self.dismiss(animated: true, completion: nil)
                            let alert = UIAlertController(title: "Added to List!", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            print("Saved item")
                        } else {
                            print("Could not save item: \(error)")
                        }
                    }
                } else { //Item exists in list
                    //Alert user
                    let alert = UIAlertController(title: "This item already exists in this list", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else {
                print("Could not find objects: \(error)")
            }
        }
    }

}
