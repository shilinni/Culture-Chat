//
//  RegisterViewController.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 11/18/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordTwo: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var validLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email.delegate=self
        password.delegate=self
        passwordTwo.delegate=self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == email {
            textField.resignFirstResponder()
            password.becomeFirstResponder()
            return true
        }
        if textField == password {
            textField.resignFirstResponder()
            passwordTwo.becomeFirstResponder()
            return true
        }
        if textField == passwordTwo{
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func editingChanged(_ sender: UITextField) {
        registerButton.isEnabled=false
        if password.text == passwordTwo.text {
            registerButton.isEnabled=true
            validLabel.text=""
        }
        else{
            validLabel.text="Please enter the same password."
        }
    }

    
    @IBAction func register(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            if error != nil {
                self.validLabel.text=error?.localizedDescription ?? "register error"
            }
            else {
                let newUser = Database.database().reference().child("users").child(user!.uid)
                newUser.setValue(["username" : "", "uid": "\(user!.uid)", "profileURL": "", "coins": 100])
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let navigation = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = navigation
            }
        }
        
    }
    
    @IBAction func backToLogin(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
