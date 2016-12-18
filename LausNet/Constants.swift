//
//  Constants.swift
//  LausNet
//
//  Created by Stephan Lerner on 21.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation
import UIKit
import Firebase

let SHADOW_COLOR: CGFloat = 157.0 / 255.0

//UserDefaults
let KEY_USER_ID = "userId"
let KEY_USER_PROVIDER = "userProvider"
let KEY_USER_NAME = "userName"
let KEY_USER_IMAGE_ID = "userImageId"

//Segues
let SEGUE_LOGGED_IN = "FeedVC"
let SEGUE_SETTINGS = "ProfileVC"
let SEGUE_COMMENTS = "CommentVC"

//Status Codes
let STATUS_ACCOUNT_NONEXIST = 17011

//Firebase References
let CHILD_USERS = "users"
let CHILD_POSTS = "posts"
let CHILD_IMAGES = "images"

//Firbase Keys
let KEY_POST_LIKES = "postLikes"
let KEY_POST_DESCRIPTION = "postDescription"
let KEY_POST_LIKED = "postLiked"
let KEY_POST_IMAGE_ID = "postImageId"
let KEY_POST_COMMENTS = "postComments"
let KEY_POST_COMMENT_TEXT = "postCommentText"
