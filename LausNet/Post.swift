//
//  Post.swift
//  LausNet
//
//  Created by Stephan Lerner on 25.11.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation

class Post {
    private var _postId: String!
    private var _userId: String!
    private var _postDescription: String!
    private var _postLikes: Int!
    private var _postImageId: String?
    private var _postLiked: Dictionary<String, Bool>?
    
    var postId: String {
        return _postId
    }
    
    var userId: String {
        return _userId
    }
    
    var postDescription: String {
        return _postDescription
    }
    
    var postLikes: Int {
        return _postLikes
    }
    
    var postImageId: String? {
        return _postImageId
    }
    
    var postLiked: Dictionary<String, Bool>? {
        return _postLiked
    }
    
    init(postId: String, dictionary: Dictionary<String, AnyObject>) {
        self._postId = postId
        self._userId = dictionary[KEY_USER_ID] as? String ?? ""
        self._postDescription = dictionary[KEY_POST_DESCRIPTION] as? String ?? ""
        self._postLikes = dictionary[KEY_POST_LIKES] as? Int ?? 0
        self._postImageId = dictionary[KEY_POST_IMAGE_ID] as? String ?? nil
        self._postLiked = dictionary[KEY_POST_LIKED] as? Dictionary<String, Bool> ?? nil
    }
}
