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
        
        //Width of phone / 2
        let width = collectionView.frame.size.width * (1/2)
        //Size of each item in collection view
        layout.itemSize = CGSize(width: width, height: width)
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        //Bind refreshControl to action
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        //Bind control to tableView
        collectionView.refreshControl = refreshControl
        
        //Change navigation bar color
        self.navigationController?.navigationBar.barTintColor = UIColor(named: "blue1")
    }
    
    @objc private func refreshControlAction(_ refreshControl: UIRefreshControl) {
        retrieveLists()
        refreshControl.endRefreshing()
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
            cell.listTitleLabel.alpha = 1
            cell.editListButton.alpha = 0.5
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            print("Cancel")
        }
        
        alert.addAction(deleteListAction)
        alert.addAction(addPhotoAction)
        alert.addAction(changeTitleAction)
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
            
        } else {
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
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! ListCell
        let indexPath = collectionView.indexPath(for: cell)!
        let list = lists[(lists.count-1)-indexPath.row]
        
        let customListViewController = segue.destination as! CustomListViewController
        customListViewController.list = list
    }

}
