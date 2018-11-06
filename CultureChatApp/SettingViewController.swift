//
//  SettingViewController.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 12/4/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorageUI
import GoogleSignIn

class SettingViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate{

    @IBOutlet weak var avadarImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var coins: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var editButton: UIButton!
    
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate=self
        userName.delegate=self
        userName.isUserInteractionEnabled = false
        
        //change Avadar to circular
        self.avadarImageView.layer.cornerRadius = self.avadarImageView.frame.size.width / 2
       
        //tap gesture setup
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        avadarImageView.addGestureRecognizer(tapGestureRecognizer)
        
        //email address
        emailLabel.text=Auth.auth().currentUser!.email
        //avadarImageView.image = Auth.auth().currentUser?.photoURL
        
        //print(Auth.auth().currentUser?.photoURL)
        /*let number=Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)").value(forKey: "coins") as! String?*/

        //coins
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
        userRef.observe(.value) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let number = dict["coins"]
                self.coins.text="\(number!)"
                let name = dict["username"]
                self.userName.text="\(name!)"
             
                /*if let downloadUrl = dict["profileURL"] as? String {
                    
                    
                    self.avadarImageView.image = UIImage(data: <#T##Data#>)
                }
                let uid = Auth.auth().currentUser?.uid
                let i2 = Storage.storage().reference().child("\(uid!).png")
                */
                
            }
        }
        
        // Reference to an image file in Firebase Storage
        let uid = Auth.auth().currentUser?.uid
        
        //if Storage.storage().reference()
        
        let storageRef = Storage.storage().reference().child("\(uid!).png")
        
        storageRef.downloadURL(completion: { (url, error) in
            if url == nil {
                return
            }
            let data = try? Data.init(contentsOf: url!)
                self.avadarImageView.image=UIImage(data: data!)
        })
        
        // UIImageView in your ViewController
        //let imageView: UIImageView = self.imageView
        
        // Placeholder image
        //let placeholderImage = UIImage(named: "userPhoto2")
        
        // Load the image using SDWebImage
        //avadarImageView.sd_setImage(with: storageRef, placeholderImage: placeholderImage)
        
    }
    
    //tap gesture
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
       // let tappedImage = tapGestureRecognizer.view as! UIImageView
        addAlertSheet()
        
    }
    
    func addAlertSheet(){
        let actionSheet=UIAlertController(title: "change avadar", message: nil, preferredStyle: .actionSheet)
        let takePhoto = UIAlertAction(title: "Take Photo", style: .destructive) { (takePhoto) in
            self.takePhotoAction()
        }
        actionSheet.addAction(takePhoto)
        
        let uploadPhoto = UIAlertAction(title: "Choose from Album", style: .destructive) { (uploadPhoto) in
            self.uploadPhotoAction()
        }
        actionSheet.addAction(uploadPhoto)
        
        let cancel=UIAlertAction(title: "Cancel", style: .cancel) {
            (cancel) in
        }
        actionSheet.addAction(cancel)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    //alert actions
    func takePhotoAction(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.picker.allowsEditing = true
            self.picker.sourceType = UIImagePickerControllerSourceType.camera
            self.picker.cameraCaptureMode = .photo
            self.picker.modalPresentationStyle = .fullScreen
            self.present(self.picker,animated: true,completion: nil)
        }else{
            let alert = UIAlertController.init(title: "Oops", message: "Your device has no camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func uploadPhotoAction(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.picker.allowsEditing = true
                self.picker.sourceType = .photoLibrary
                self.present(self.picker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController.init(title: "Oops", message: "Your device has no photo library", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //logout
    @IBAction func logout(_ sender: UIButton) {
        
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                GIDSignIn.sharedInstance().signOut()
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginControllerID")
                present(viewController, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
  
    }
    
    //imagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.avadarImageView.image = editedImage
        }else{
            self.avadarImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        imageToFirebase(withImage: avadarImageView.image!)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //upload image to firebase
    func imageToFirebase(withImage image: UIImage){
        logoutButton.isEnabled = false
        let uid = Auth.auth().currentUser?.uid
        
        let storageRef = Storage.storage().reference().child("\(uid!).png")
        if let uploadData = UIImagePNGRepresentation(image) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                //alert: successfully uploaded
                //print(metadata?.downloadURL())
                let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
                if let profileURL = metadata?.downloadURL()?.absoluteString{
                    let value = ["profileURL": profileURL]
                    userRef.updateChildValues(value, withCompletionBlock: { (err, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        self.logoutButton.isEnabled = true
                        //self.dismiss(animated: true, completion: nil)
                    })

                }
                
            })
            
        }
        
        
        
        /*let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.photoURL = URL(string: image)
            changeRequest?.commitChanges(completion: { (error) in
                
            })*/
    }
    
    @IBAction func editUserName(_ sender: UIButton) {
        self.userName.isUserInteractionEnabled = true
        sender.isHidden = true
        self.userName.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            textField.resignFirstResponder()
            self.editButton.isHidden = false
            textField.isUserInteractionEnabled = false
            self.updateUserName(username: textField.text!)
            
            return true
        }
        return false
    }
    
    func updateUserName (username: String){
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
        userRef.updateChildValues(["username": username]) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
        }
    }
    
}
