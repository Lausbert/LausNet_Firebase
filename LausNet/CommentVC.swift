//
//  CommentVC.swift
//  LausNet
//
//  Created by Stephan Lerner on 06.12.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit
import Firebase

class CommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var DeleteBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTxt: MaterialTextField!
    
    var postCell: PostCell? = nil
    var comments: [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.commentTxt.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 340
        
        if postCell?.post.userId == UserDefaults.standard.value(forKey: KEY_USER_ID) as? String {
            DeleteBtn.isEnabled = true
        } else {
            DeleteBtn.isEnabled = false
        }
        
        DataService.ds.REF_POSTS.child((postCell?.post.postId)!).child(KEY_POST_COMMENTS).observe(.value, with: { snapshot in
            
            self.comments = []
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
                for snap in snapshots {
                    
                    if let commentDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let comment = Comment(commentId: key, dictionary: commentDict)
                        self.comments.append(comment)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as? CommentCell {
            cell.configureCell(comment: comment)
            return cell
        }else {
            return CommentCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return postCell
    }
    
    // MARK: Buttons
    
    @IBAction func pressedCancelBtn(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pressedDeleteBtn(_ sender: Any) {
        showDeleteAlert()
    }
    
    @IBAction func pressedSendBtn(_ sender: Any) {
        if let txt = commentTxt.text, txt != "" {
            
            let commentData = [KEY_POST_COMMENT_TEXT: txt as AnyObject] as Dictionary<String, AnyObject>
            
            DataService.ds.createFirebaseComment(commentData: commentData, post: (self.postCell?.post)!)
            
            commentTxt.text = ""
        }
    }
    
    // MARK: Text Field Behaviour
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    // MARK: Alerts
    
    func showDeleteAlert() {
        let alert = UIAlertController(title: "Delete", message: "Press OK to continue.", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            DataService.ds.deleteFirebasePost(post: (self.postCell?.post)!)
            _ = self.navigationController?.popViewController(animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)    }
}
