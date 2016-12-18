//
//  ViewController.swift
//  LausNet
//
//  Created by Stephan Lerner on 21.10.16.
//  Copyright © 2016 Stephan. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var passwordField: MaterialTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.value(forKey: KEY_USER_ID) != nil {
            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
        }
    }
    
    // MARK: Buttons
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            if (error != nil){
                print("Facebook login failed. Error \(error)")
            } else {
                let accessToken = FBSDKAccessToken.current().tokenString
                print("Successfully logged in with facebook. \(accessToken)")
                
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: accessToken!)
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged IN!\(user)")
                        
                        UserDefaults.standard.set(user?.uid, forKey: KEY_USER_ID)
                        let userData = ["provider": "facebook" as AnyObject] as Dictionary<String, AnyObject>
                        DataService.ds.updateFirebaseUser(userData: userData)
                        
                        self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func attemptLogin(sender:UIButton!) {
        if let email = emailField.text , email != "", let pwd = passwordField.text, pwd != "" {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if let er = error as NSError?, error != nil {
                    print(er)
                    
                    if er.code == STATUS_ACCOUNT_NONEXIST {
                        FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                            
                            if error != nil {
                                self.present(showErrorAlert(title: "Could not create account", msg: "Problem creating account. Try something else"), animated: true, completion: nil)
                            } else {
                                
                                FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                                    
                                    UserDefaults.standard.set(user?.uid, forKey: KEY_USER_ID)
                                    let userData = ["provider": "email" as AnyObject] as Dictionary<String, AnyObject>
                                    DataService.ds.updateFirebaseUser(userData: userData)
                                })
                                self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                            }
                        })
                    } else {
                        self.present(showErrorAlert(title: "Could not log in", msg: "Please check your username or your password"), animated: true, completion: nil)
                    }
                } else {
                    UserDefaults.standard.set(user?.uid, forKey: KEY_USER_ID)
                    self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                }
            })
            
        } else {
            self.present(showErrorAlert(title: "Email and Password Required", msg: "Please enter an email and a password"), animated: true, completion: nil)
        }
    }
    
    // MARK: Text Field Behaviour
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

