//
//  ProfileVC.swift
//  LausNet
//
//  Created by Stephan Lerner on 28.11.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var userImg: MaterialProfile!
    @IBOutlet weak var userTxt: MaterialTextField!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        self.userTxt.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if let userName = UserDefaults.standard.value(forKey: KEY_USER_NAME) as? String {
            userTxt.text = userName
            
            if let imageId = UserDefaults.standard.value(forKey: KEY_USER_IMAGE_ID) as? String {
                DataService.ds.downloadImage(imageId: imageId) { userImage in
                    self.userImg.image = userImage
                }
            }
        } else {
            DataService.ds.getFirebaseUser(userId: UserDefaults.standard.value(forKey: KEY_USER_ID) as! String) { userDict in
                if let userName = userDict?[KEY_USER_NAME] as? String {
                    self.userTxt.text = userName
                    UserDefaults.standard.set(userName, forKey: KEY_USER_NAME)
                    
                    if let imageId = userDict?[KEY_USER_IMAGE_ID] as? String {
                        DataService.ds.downloadImage(imageId: imageId) { userImage in
                            self.userImg.image = userImage
                            UserDefaults.standard.set(imageId, forKey: KEY_USER_IMAGE_ID)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: ImagePickerController
    
    var imageSelected = false
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImg.image = image
            imageSelected = true
        } else {
            print("imagePickerController error: image could not be loaded")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Button
    
    @IBAction func selectImage(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pressedSaveButton(_ sender: Any) {
        if let txt = userTxt.text, txt != "" {
            var userData = ["userName" : "\(txt)" as AnyObject] as Dictionary<String, AnyObject>
            if let img = userImg.image, imageSelected {
                DataService.ds.uploadImage(image: img) { userImageId in
                    userData[KEY_USER_IMAGE_ID] = userImageId as AnyObject?
                    DataService.ds.updateFirebaseUser(userData: userData)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            } else {
                DataService.ds.updateFirebaseUser(userData: userData)
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func pressedCancelBtn(_ sender: Any) {
        
        if UserDefaults.standard.value(forKey: KEY_USER_NAME) == nil {
            present(showErrorAlert(title: "User name required", msg: "Please enter a username"), animated: true, completion: nil)
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: Text Field Behaviour
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
