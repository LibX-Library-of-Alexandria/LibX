//
//  ListsViewController.swift
//  Pods
//
//  Created by Mina Kim on 11/23/20.
//

import UIKit
import Parse

class ListsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var lists = [PFObject]()
    var selectedList : PFObject!
    
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
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        //Bind refreshControl to action
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        //Bind control to tableView
        collectionView.refreshControl = refreshControl
        
        //Removes text in back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        //Change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "blue1")
    }
    
    @objc private func refreshControlAction(_ refreshControl: UIRefreshControl) {
        retrieveLists()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //Change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "blue1")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        retrieveLists()
    }
    
    func retrieveLists() {
        print("Retrieving lists")
        
        let query = PFQuery(className: "Lists").whereKey("user", equalTo: PFUser.current()!)
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
            cell.containerView.alpha = 0.65
            cell.listTitleLabel.alpha = 1
            cell.editListButton.alpha = 0.65
            cell.editListButton.tag = indexPath.row //Associates button with specific cell
            
            if let imageFile = list["photo"] as? PFFileObject { //Checks if list has photo
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                cell.listImage.af_setImage(withURL: url)
            }
                        
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
                textField.autocapitalizationType = .words
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                if let input = alert?.textFields?.first?.text {
                    print("Input: \(input)")
                    
                    //POST to Parse
                    let list = PFObject(className: "Lists")
                    let imageData = UIImage(named: "camera.png")?.pngData()
                    let file = PFFileObject(data: imageData!)
                    
                    list["title"] = input
                    list["user"] = PFUser.current()
                    list["photo"] = file
                    
                    list.saveInBackground { (success, error) in
                        if success {
                            print("Successfully saved list \(input)")
                            self.retrieveLists()
                        } else {
                            print("Could not save list")
                        }
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Function for editing lists
    @IBAction func editList(_ sender: Any) {
        let button = sender as! UIButton
        let listNum = button.tag
        let list = lists[(lists.count-1)-listNum]
        print("Edit list " + (list["title"] as! String))
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteListAction = UIAlertAction(title: "Delete List", style: .destructive) { (UIAlertAction) in
            self.editList(result: "delete", list: list)
        }
        let addPhotoAction = UIAlertAction(title: "Edit Photo", style: .default) { (UIAlertAction) in
            self.editList(result: "photo", list: list)
        }
        let changeTitleAction = UIAlertAction(title: "Edit Title", style: .default) { (UIAlertAction) in
            self.editList(result: "title", list: list)
        }
        let shareList = UIAlertAction(title: "Share", style: .default) { (UIAlertAction) in
            self.editList(result: "share", list: list)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            print("Cancel")
        }
        
        alert.addAction(deleteListAction)
        alert.addAction(addPhotoAction)
        alert.addAction(changeTitleAction)
        alert.addAction(shareList)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    private func editList(result: String, list: PFObject) {
        let title = list["title"] as! String
        
        if result == "delete" {
            print("Delete this item: " + title)
            
            let alert = UIAlertController(title: "Delete List?", message: "Deleting will delete all items associated with the list", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (UIAlertAction) in
                //DESTROY items in list
                let query = PFQuery(className: "Items").whereKey("list", equalTo: list)
                query.findObjectsInBackground { (items, error) in
                    if items != nil {
                        for item in items! {
                            item.deleteInBackground()
                        }
                    } else {
                        print("Could not find items: \(error)")
                    }
                }
                
                //DESTROY list
                list.deleteInBackground { (success, error) in
                    if success {
                        print("Deleted list")
                        self.retrieveLists()
                    } else {
                        print("Could not delete list")
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else if result == "photo" {
            print("Change photo of: " + title)
            
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            //List to edit
            selectedList = list
            present(picker, animated: true, completion: nil)
            
        } else if result == "title" {
            print("Change title of: " + title)
            
            let alert = UIAlertController(title: "Edit title", message: "Enter new title", preferredStyle: .alert)
            alert.addTextField(configurationHandler: { textField in
                textField.placeholder = "List Title"
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                if let input = alert?.textFields?.first?.text {
                    list["title"] = input
                    list.saveInBackground { (success, error) in
                        if success {
                            print("Edited title")
                            self.retrieveLists()
                        } else {
                            print("Could not edit title")
                        }
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        } else { //Share list
            let query = PFQuery(className: "Items").whereKey("list", equalTo: list)
            query.findObjectsInBackground { (items, error) in
                if items != nil {
                    print("Share list code")
                    var shareText = (list["title"] as! String) + ":"
                    for item in items! {
                        let type = item["type"] as! String
                        if type == "book" {
                            let book = item["details"] as! [String:Any]
                            let bookInfo = book["volumeInfo"] as! [String:Any]
                            let title = bookInfo["title"] as! String
                            let authors = bookInfo["authors"] as! [String]
                            let author = authors[0]
                            //Add book title & author
                            shareText += ",\n" + title + ", " + author
                        } else if type == "movie" {
                            let movie = item["details"] as! [String:Any]
                            let title = movie["title"] as! String
                            //Add movie title
                            shareText += ",\n" + title
                        } else if type == "show" {
                            let show = item["details"] as! [String:Any]
                            let title = show["name"] as! String
                            //Add show title
                            shareText += ",\n" + title
                        }
                    }
                    shareText = shareText.replacingOccurrences(of: ":,", with: ":")
                    //Retrieves image url/data
                    let imageFile = list["photo"] as! PFFileObject
                    let urlString = imageFile.url!
                    let url = URL(string: urlString)!
                    let data = NSData(contentsOf: url)!
                    let image = UIImage(data: data as Data)
                    //Sharing outside app
                    guard
                        let urlData = self.exportToUrl(list: list)
                    else { return }
                    //Show UIActivityViewController
                    let vc = UIActivityViewController(activityItems: [shareText, urlData], applicationActivities: [])
                    self.present(vc, animated: true)
                } else {
                    print("Couldn't find items: \(error)")
                }
            }
        }
    }
    
    //Picking images from camera roll
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
            
        //Adjusts size of image
        let width = self.view.frame.width * (1/2)
        let size = CGSize(width: width, height: width)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        //Saves image in database
        let imageData = image.pngData()
        let file = PFFileObject(data: imageData!)
        selectedList["photo"] = file

        selectedList.saveInBackground { (success, error) in
            if success{
                print("Edited photo")
                self.collectionView.reloadData()
            } else {
                print("Could not edit photo: \(error)")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Sharing feature
    //Reads in imported data from libx files
    static func importData(from url: URL) {
        print("Importing Data")
        //Verify file can be read
        guard
            let data = try? Data(contentsOf: url),
            let dictionary = try? JSONDecoder().decode([String:String].self, from: data)
        else { return }
        
        //Add data to app
        let id = dictionary["objectId"]!
        let query = PFQuery(className: "Lists").whereKey("objectId", equalTo: id)
        let list = query.getFirstObjectInBackground() //Maybe findObjectsInBackground()?
        let query1 = PFQuery(className: "Items").whereKey("list", equalTo: list)
        query1.findObjectsInBackground { (objects, error) in
            if objects != nil {
                let items = objects!
                var itemsCopy = [PFObject]()
                for item in items {
                    itemsCopy.append(item.copy() as! PFObject)
                }
                let listCopy = list.copy() as! PFObject
                listCopy["user"] = PFUser.current()! //Changes user
                listCopy.saveInBackground()
                for itemCopy in itemsCopy {
                    itemCopy["list"] = listCopy //Get list first?
                    itemCopy.saveInBackground()
                }
                print("Finished importing")
            } else {print("Error in finding objects")}
        }
        
        //Delete file after opening
        try? FileManager.default.removeItem(at: url)
    }
    //Export data
    func exportToUrl(list: PFObject) -> URL? {
        //Convert data to JSON
        print(list.objectId)
        let objectId = list.objectId as! String
        let dictionary = ["objectId" : objectId] as [String:String]
        guard let encoded = try? JSONEncoder().encode(dictionary) else { return nil }
        
        //Verify can access Documents dierctory w/o error
        let documents = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first
        guard let path = documents?.appendingPathComponent("/\(list["title"]).libx") else {
            return nil
        }
        
        //Save data to Documents director & return URL of created file
        do {
            try encoded.write(to: path, options: .atomicWrite)
            return path
        } catch {
            print(error.localizedDescription)
            return nil
      }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! ListCell
        let indexPath = collectionView.indexPath(for: cell)!
        let list = lists[(lists.count-1)-indexPath.row]
        
        let customListViewController = segue.destination as! CustomListViewController
        customListViewController.list = list
    }

}
