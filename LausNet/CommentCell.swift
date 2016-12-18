//
//  CommentCell.swift
//  LausNet
//
//  Created by Stephan Lerner on 08.12.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var userLbl: UILabel!
    @IBOutlet weak var commentTxt: UILabel!
    
    func configureCell(comment: Comment) {
        self.commentTxt.text = comment.commentText
        DataService.ds.getFirebaseUser(userId: comment.userId) { userDict in
            self.userLbl.text = userDict?[KEY_USER_NAME] as? String ?? ""
        }
    }
}
