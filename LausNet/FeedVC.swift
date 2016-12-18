//
//  FeedVC.swift
//  LausNet
//
//  Created by Stephan Lerner on 24.11.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var postImg: UIImageView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.postField.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 340
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { snapshot in
            
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postId: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: KEY_USER_NAME) == nil {
            self.performSegue(withIdentifier: SEGUE_SETTINGS, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    // MARK: TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            cell.configureCell(post: post)
            return cell
        }else {
            return PostCell()
        }
    }
    
    // MARK: ImagePickerConroller
    
    var imageSelected = false
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            postImg.image = image
            imageSelected = true
        } else {
            print("imagePickerController error: image could not be loaded")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Buttons
    
    @IBAction func selectImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(_ sender: Any) {
        if let txt = postField.text, txt != "" {
            
            var postData = [KEY_POST_DESCRIPTION: txt as AnyObject] as Dictionary<String, AnyObject>
            
            if let img = postImg.image, imageSelected{
                DataService.ds.uploadImage(image: img) { postImageId in
                    postData[KEY_POST_IMAGE_ID] = postImageId as AnyObject?
                    DataService.ds.createFirebasePost(postData: postData)
                    
                }
            } else {
                DataService.ds.createFirebasePost(postData: postData)
            }
            
            postField.text = ""
            postImg.image = UIImage(named: "camera")
            imageSelected = false
        }
    }
    
    // MARK: Text Field Behaviour
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SEGUE_COMMENTS {
            let viewController = segue.destination as! CommentVC
            
            if let cell = sender as? PostCell {
                viewController.postCell = cell
            }
        }
    }
}
