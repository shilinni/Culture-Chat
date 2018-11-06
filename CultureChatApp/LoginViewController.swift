//
//  LoginViewController.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 11/18/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase

class LoginViewController: UIViewController,UITextFieldDelegate,GIDSignInUIDelegate,GIDSignInDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var validLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate=self
        passwordTextField.delegate=self
        self.hideKeyboardWhenTappedAround()
        loginButton.isEnabled=false
        GIDSignIn.sharedInstance().clientID="xxxxxxx.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance().delegate=self
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil {
                self.validLabel.text=error?.localizedDescription ?? "register error"
            }
            else {
                /*let newUser = Database.database().reference().child("users").child(user!.uid)
                newUser.setValue(["username" : "", "uid": "\(user!.uid)", "profileURL": ""])*/
                self.changeInitialViewController()
            }
        }
 
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
        Auth.auth().signIn(with: credential, completion: {
            (user, error) in    
            if error != nil {
                self.validLabel.text=error?.localizedDescription ?? "Google sign in error"
                return
            }else{
                /*let newUser = Database.database().reference().child("users").child(user!.uid)
                newUser.updateChildValues(["username" : "\(user!.displayName!)", "uid": "\(user!.uid)", "profileURL": "\(user!.photoURL!)"])
            */
                let ref = Database.database().reference().child("users")
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.hasChild("\(user!.uid)"){
                        
                    }else{
                        let newUser = Database.database().reference().child("users").child(user!.uid)
                        newUser.updateChildValues(["username" : "\(user!.displayName!)", "uid": "\(user!.uid)", "profileURL": "\(user!.photoURL!)","coins": 100])
                    }
                })
                self.changeInitialViewController()
            }
        })
    }
    
    //check if the email addr is valid
    @IBAction func editingChanged(_ sender: UITextField) {
        loginButton.isEnabled=false
        validLabel.text=""
        if let text=emailTextField.text {
            if text.isValidEmail() {
                if passwordTextField.text != "" {
                    loginButton.isEnabled=true
                }
            }
            else{
                validLabel.text="Invalid email address"
            }
        }
    }
    
    func changeInitialViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigation = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = navigation
    }
    
    //return button on keyboard hitted.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
            return true
        }
        if textField == passwordTextField{
            textField.resignFirstResponder()
        }
        return true
    }
    
    
    @IBAction func register(_ sender: UIButton) {
    }
    
    @IBAction func googleLogin(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }

}
