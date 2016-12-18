//
//  DataService.swift
//  LausNet
//
//  Created by Stephan Lerner on 21.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    
    // MARK: Singleton
    
    static let ds = DataService()
    
    // MARK: Caches
    
    static var imageCache = NSCache<AnyObject, AnyObject>()
    static var userCache = NSCache<AnyObject, AnyObject>()
    
    // MARK: References
    
    private var _REF_DATABASE: FIRDatabaseReference
    private var _REF_POSTS: FIRDatabaseReference
    private var _REF_USERS: FIRDatabaseReference
    
    private var _REF_STORAGE: FIRStorageReference
    private var _REF_IMAGES: FIRStorageReference
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_DATABASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_CURRENT_USER: FIRDatabaseReference {
        let uid = UserDefaults.standard.value(forKey: KEY_USER_ID) as! String
        return _REF_USERS.child(uid)
    }
    
    var REF_STORAGE: FIRStorageReference {
        return _REF_STORAGE
    }
    
    var REF_IMAGES: FIRStorageReference {
        return _REF_IMAGES
    }
    
    // MARK: Initialization
    
    init() {
        _REF_DATABASE = FIRDatabase.database().reference()
        _REF_POSTS = _REF_DATABASE.child(CHILD_POSTS)
        _REF_USERS = _REF_DATABASE.child(CHILD_USERS)
        
        _REF_STORAGE = FIRStorage.storage().reference()
        _REF_IMAGES = _REF_STORAGE.child(CHILD_IMAGES)
    }
    
    // MARK: Firebase User
    
    func updateFirebaseUser(userData: Dictionary<String, AnyObject>) {
        
        if let _ = userData[KEY_USER_PROVIDER] {
            UserDefaults.standard.set(userData[KEY_USER_PROVIDER], forKey: KEY_USER_PROVIDER)
        }
        if let _ = userData[KEY_USER_NAME] {
            UserDefaults.standard.set(userData[KEY_USER_NAME], forKey: KEY_USER_NAME)
        }
        if let _ = userData[KEY_USER_IMAGE_ID] {
            UserDefaults.standard.set(userData[KEY_USER_IMAGE_ID], forKey: KEY_USER_IMAGE_ID)
        }
        
        let uid = UserDefaults.standard.value(forKey: KEY_USER_ID) as! String
        DataService.userCache.setObject(userData as AnyObject, forKey: uid as AnyObject)
        _REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func getFirebaseUser(userId: String, completion: @escaping (Dictionary<String, AnyObject>?) -> ()) {
        if let userDict = DataService.userCache.object(forKey: userId as AnyObject) as? Dictionary<String, AnyObject> {completion(userDict); return}
        REF_USERS.child(userId).observeSingleEvent(of: .value, with: { snapshot in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                DataService.userCache.setObject(userDict as AnyObject, forKey: userId as AnyObject)
                completion(userDict)
            } else {
                completion(nil)
            }
        }) { (error) in
            print(error)
        }
    }
    
    //Mark: Firebase Post
    
    func createFirebasePost(postData: Dictionary<String, AnyObject>) {
        var newPostData = postData
        newPostData[KEY_POST_LIKES] = 0 as AnyObject?
        newPostData[KEY_USER_ID] = UserDefaults.standard.value(forKey: KEY_USER_ID) as AnyObject?
        _REF_POSTS.childByAutoId().setValue(newPostData)
    }
    
    func deleteFirebasePost(post: Post) {
        if let postImageId = post.postImageId {
            deleteFirebasePostImage(postImageId: postImageId)
        }
        _REF_POSTS.child(post.postId).removeValue()
    }
    
    func updateLikes(postId: String) {
        _REF_POSTS.child(postId).runTransactionBlock({ (data) -> FIRTransactionResult in
            
            if var post = data.value as? Dictionary<String, AnyObject> {
                var liked = post[KEY_POST_LIKED] as? [String:Bool] ?? [:]
                var likes = post[KEY_POST_LIKES] as? Int ?? 0
                let uid = UserDefaults.standard.value(forKey: KEY_USER_ID) as! String
                if liked[uid] != nil {
                    likes -= 1
                    liked.removeValue(forKey: uid)
                } else {
                    likes += 1
                    liked[uid] = true
                }
                post[KEY_POST_LIKED] = liked as AnyObject?
                post[KEY_POST_LIKES] = likes as AnyObject?
                
                data.value = post
                
                return FIRTransactionResult.success(withValue: data)
            }
            return FIRTransactionResult.success(withValue: data)
        }) { (error, commited, snapshit) in
            if error != nil {
                print(error!)
            }
        }
    }
    
    //Mark: Firebase Comments
    
    func createFirebaseComment(commentData: Dictionary<String, AnyObject>, post: Post) {
        var newCommentData = commentData
        newCommentData[KEY_USER_ID] = UserDefaults.standard.value(forKey: KEY_USER_ID) as AnyObject?
        _REF_POSTS.child(post.postId).child(KEY_POST_COMMENTS).childByAutoId().setValue(newCommentData)
    }
    
    // Mark: Firebase Images
    
    func uploadImage(image: UIImage, completion: @escaping (String?) -> ()) {
        
        if let _ = UserDefaults.standard.value(forKey: KEY_USER_IMAGE_ID) as? String {
            self.deleteFirebaseUserImage()
        }
        
        let imgData = UIImageJPEGRepresentation(image, 0.2)
        let ImageId = UUID().uuidString
        _REF_IMAGES.child(ImageId).put(imgData!, metadata: nil) { (metadata, error) in
            if error != nil {
                print(error!)
            } else {
                if let imageId = metadata!.name {
                    completion(imageId)
                    DataService.imageCache.setObject(image, forKey: imageId as AnyObject)
                } else {
                    completion(nil)
                    print("Error: could not retrieve imageID.")
                }
            }
        }
    }
    
    func deleteFirebaseUserImage() {
        let uid = UserDefaults.standard.value(forKey: KEY_USER_ID) as! String
        let userImageId = UserDefaults.standard.value(forKey: KEY_USER_IMAGE_ID) as! String
        
        _REF_USERS.child(uid).child(KEY_USER_IMAGE_ID).removeValue()
        _REF_IMAGES.child(userImageId).delete { error in
            if error != nil {
                print(error!)
            }
        }
        
        UserDefaults.standard.set(nil, forKey: KEY_USER_IMAGE_ID)
    }
    
    func deleteFirebasePostImage(postImageId: String) {
        _REF_IMAGES.child(postImageId).delete { error in
            if error != nil {
                print(error!)
            }
        }
    }
    
    func downloadImage(imageId: String, completion: @escaping (UIImage?) -> ()) {
        if let img = DataService.imageCache.object(forKey: imageId as AnyObject) as? UIImage {completion(img); return}
        _REF_IMAGES.child(imageId).data(withMaxSize: 2*1024*1024) { (data, error) in
            if error != nil {
                print(error!)
            } else {
                if let img = UIImage(data: data!) {
                    DataService.imageCache.setObject(img, forKey: imageId as AnyObject)
                    completion(img)
                } else {
                    print("Error: Could not download image.")
                    completion(nil)
                }
            }
        }
    }
}


