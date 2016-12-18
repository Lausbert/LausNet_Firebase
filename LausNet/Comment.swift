//
//  Comment.swift
//  LausNet
//
//  Created by Stephan Lerner on 08.12.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation

class Comment {
    
    private var _commentId: String
    private var _userId: String
    private var _commentText: String
    
    var commentId: String {
        return _commentId
    }
    
    var userId: String {
        return _userId
    }
    
    var commentText: String {
        return _commentText
    }
    
    init(commentId: String, dictionary: Dictionary<String, AnyObject>) {
        self._commentId = commentId
        self._userId = dictionary[KEY_USER_ID] as? String ?? ""
        self._commentText = dictionary[KEY_POST_COMMENT_TEXT] as? String ?? ""
    }
}
