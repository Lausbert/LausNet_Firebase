//
//  PostCell.swift
//  LausNet
//
//  Created by Stephan Lerner on 24.11.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userImg: MaterialProfile!
    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var post: Post!

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action:#selector(self.likeTapped(sender:)))
            tap.numberOfTapsRequired = 1
            likeImg.addGestureRecognizer(tap)
            likeImg.isUserInteractionEnabled = true
    }
    
    override func draw(_ rect: CGRect) {
        showcaseImg.clipsToBounds = true
    }

    func configureCell(post: Post) {
        self.post = post
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.postLikes)"
        
        if post.postImageId != nil {
            DataService.ds.downloadImage(imageId: post.postImageId!) { image in
                if let img = image{
                    self.showcaseImg.image = img
                    self.showcaseImg.isHidden = false
                } else {
                    self.showcaseImg.isHidden = true
                }
            }
        } else {
            self.showcaseImg.isHidden = true
        }
        
        DataService.ds.getFirebaseUser(userId: post.userId) { userDict in
            self.userLbl.text = userDict?[KEY_USER_NAME] as? String ?? ""
            if let userImageId = userDict?[KEY_USER_IMAGE_ID] as? String {
                DataService.ds.downloadImage(imageId: userImageId) { image in
                    if let img = image {
                        self.userImg.image = img
                    }
                }
            } else {
                self.userImg.image = UIImage(named: "profile")
            }
        }
        
        let uid = UserDefaults.standard.value(forKey: KEY_USER_ID) as! String
        if post.postLiked?[uid] != nil {
            likeImg.image = UIImage(named: "heart-full")
        } else {
            likeImg.image = UIImage(named: "heart-empty")
        }

    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        DataService.ds.updateLikes(postId: post.postId)
    }
}
