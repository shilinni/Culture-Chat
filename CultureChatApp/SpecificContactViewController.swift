//
//  SpecificContactViewController.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 12/10/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SpecificContactViewController: UIViewController {

    var contactID : String?
    var contactName : String?
    var uid = String()
    var channelID : String?
    
    var userRef = DatabaseReference()
    var count = 0
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var onlineStatus: UIImageView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var table: UITableView!

    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet var times: [UILabel]!
    @IBOutlet var language: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        uid = Auth.auth().currentUser!.uid
        userRef = Database.database().reference().child("users").child("\(uid)").child("schedules")
        if let name = contactName {
            nameLabel.text=name
        }
        
        for i in 0...2 {
            times[i].isHidden = true
            language[i].isHidden = true
        }
        
        if let id = contactID {
            userRef.observe(.childAdded, with: { (snapshot) in
                if snapshot.exists(){
                    let scheduleRef = Database.database().reference().child("schedules").child("\(snapshot.key)")
                    scheduleRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let dict = snapshot.value as? [String: String]{
                            if (dict["tutor"] == self.uid && dict["learner"] == id) || (dict["learner"] == self.uid && dict["tutor"] == id) {
                                //print("count ",self.count)
                                self.count += 1
                                let time = self.view.viewWithTag(10*self.count) as! UILabel
                                time.text=dict["time"]
                                time.isHidden = false
                                let myLanguage = self.view.viewWithTag(10*self.count+1) as! UILabel
                                myLanguage.text = dict["language"]
                                myLanguage.isHidden = false
                                
                                
                                let contactRef = Database.database().reference().child("users").child("\(self.contactID!)").child("contacts").child("\(self.uid)")
                                
                                contactRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let dict = snapshot.value as? [String: AnyObject]{
                                        self.channelID = dict["channelid"] as! String
                                        
                                        print("channelid sent")
                                        self.chatButton.isEnabled = true
                                    }
                                })
                                
                            }
                           
                        }
                    })
                }
            })
            
        }
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chatButton.isEnabled = false
        let contactRef = Database.database().reference().child("users").child("\(self.contactID!)").child("contacts").child("\(self.uid)")
        
        contactRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject]{
                self.channelID = dict["channelid"] as! String
                
                print("channelid sent")
                self.chatButton.isEnabled = true
            }
        })
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chatButton.isEnabled = false
        userRef.removeAllObservers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatSegue"{
            if let viewController = segue.destination as? ChatViewController {
                viewController.ContactID = self.contactID!
                viewController.contactName = self.contactName!
                
                viewController.channelID = self.channelID!
                viewController.title = self.contactName!
            }
        }
    }
}
