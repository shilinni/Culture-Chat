//
//  PostSchdulesTableViewController.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 11/19/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PostSchdulesTableViewController: UITableViewController {

    var languageName = String()
    var status = String()
    var schedules = [Schedule]()
    //@IBOutlet weak var addButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //addButton.layer.cornerRadius = 10
        //addButton.clipsToBounds = true
        let uid = Auth.auth().currentUser!.uid
        
        self.title=languageName
        let schedulesRef = Database.database().reference().child("schedules")
        schedulesRef.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: String?] {
                if (dict["tutor"]! != uid) && (dict["learner"]! != uid){
                    
                    if dict["language"]!  == self.languageName  {
                        //print(self.status,dict["learner"]!!,dict["tutor"]!!,dict["username"]!!)
                        if (self.status=="learner" && dict["learner"]!! == "") || (self.status=="tutor" && dict["tutor"]!! == ""){
                            //print(3)
                            let aSchedule = Schedule(learnerID: dict["learner"]!! , tutorID: dict["tutor"]!!, language: dict["language"]!! , userName: dict["username"]!! , time: dict["time"]!! , learnerName: dict["learnerName"]!!,tutorName: dict["tutorName"]!!,scheduleid: snapshot.key, coin: 90)//coin To be modified
                            self.schedules.append(aSchedule)
                            self.tableView.reloadData()
                        }
                    }// end of if dict["language"]
                    
                }//end of check if it's post by user-self
                
            }//end of if let dict
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewShedule"{
            if let viewController = segue.destination as? ScheduleViewController {
                viewController.text=self.languageName
                if status=="learner"{
                    viewController.learner=true
                }else{
                    viewController.learner=false
                }
            }
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.schedules.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostScheduleCell") as! PostScheduleTableViewCell

        cell.userName.text = schedules[indexPath.row].userName
        cell.time.text=schedules[indexPath.row].time
        cell.coins.text="90"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! PostScheduleTableViewCell
        let name = cell.userName.text!
        
        //alert: schedule check
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
        userRef.child("schedules").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.childrenCount == 3{
                let alert = UIAlertController.init(title: "Sorry", message: "You can at most schedule three appointments", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
                
                //alert
                let alert = UIAlertController.init(title: "", message: "Are you sure you want to make an appointment with \(name) and add \(name) to your contact list?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    self.addContact(withIndexPath: indexPath)
                    self.navigationController?.popViewController(animated: true)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    
                }))
                self.present(alert, animated: true, completion: nil)

                
            }//end of else block: child<=3
        }   //end of observe completion
    }//end of function
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2") as! AddButtonTableViewCell
        
        cell.add.layer.cornerRadius = cell.add.frame.size.width / 2
        
        return cell.contentView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    
    //add a name
    func addContact (withIndexPath indexPath: IndexPath) {
        let uid = Auth.auth().currentUser!.uid
        let schedule = schedules[indexPath.row].scheduleid
        let userRef = Database.database().reference().child("users").child("\(uid)")
        let scheduleRef = Database.database().reference().child("schedules").child("\(schedule)")
        var username = "Anonymous"
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject]{
                username = dict["username"] as! String
                
                scheduleRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    var otherUid = String()
                    if let scheduleDict = snapshot.value as? [String:AnyObject]{
                    
                    if self.status == "learner"{
                        otherUid = scheduleDict["tutor"] as! String
                    }else{
                        otherUid = scheduleDict["learner"] as! String
                    }
                    
                    let otherUserRef = Database.database().reference().child("users").child("\(otherUid)")
                    
                    if self.status == "learner"{
                        
                        self.schedules[indexPath.row].learnerID = uid
                        self.schedules[indexPath.row].learnerName = username
                        scheduleRef.updateChildValues(["learner": uid, "learnerName": username], withCompletionBlock: { (error, ref) in
                            if error != nil {
                                //print(error)
                                return
                            }
                        })
                        userRef.child("contacts").child("\(self.schedules[indexPath.row].tutorID!)").updateChildValues(["learningFrom": true, "username": self.schedules[indexPath.row].tutorName])
                        userRef.child("contacts").child("\(self.schedules[indexPath.row].tutorID!)").child("learning").updateChildValues(["\(self.schedules[indexPath.row].language)": true])
                        
                        otherUserRef.child("contacts").child("\(self.schedules[indexPath.row].learnerID!)").child("teaching").updateChildValues(["\(self.schedules[indexPath.row].language)": true])
                        
                        userRef.child("contacts").child("\(self.schedules[indexPath.row].tutorID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                            //print("observing channel id")
                            if snapshot.hasChild("channelid"){
                                //print("has channel id")
                            }else{
                                //print("no channel id")
                                let channel = Database.database().reference().child("channels").childByAutoId()
                                channel.setValue(["1":"1"])
                                userRef.child("contacts").child("\(self.schedules[indexPath.row].tutorID!)").updateChildValues(["channelid": channel.key])
                                otherUserRef.child("contacts").child("\(self.schedules[indexPath.row].learnerID!)").updateChildValues(["channelid": channel.key])
                            }
                        })
                        
                        
                    }
                    else{
                        
                        self.schedules[indexPath.row].tutorID = uid
                        self.schedules[indexPath.row].tutorName = username
                        scheduleRef.updateChildValues(["tutor": uid, "tutorName": username], withCompletionBlock: { (error, ref) in
                            if error != nil {
                                //print(error)
                                return
                            }
                        })
                        userRef.child("contacts").child("\(self.schedules[indexPath.row].learnerID!)").updateChildValues(["teachingTo": true, "username": self.schedules[indexPath.row].learnerName])
                        //username
                        userRef.child("contacts").child("\(self.schedules[indexPath.row].learnerID!)").child("teaching").updateChildValues(["\(self.schedules[indexPath.row].language)": true])
                        otherUserRef.child("contacts").child("\(self.schedules[indexPath.row].tutorID!)").child("learning").updateChildValues(["\(self.schedules[indexPath.row].language)": true])
                        
                        
                        userRef.child("contacts").child("\(self.schedules[indexPath.row].learnerID!)").observeSingleEvent(of: .value, with: { (snapshot) in
                            //print("observing channel id")
                            if snapshot.hasChild("channelid"){
                                //print("has channel id")
                            }else{
                                //print("no channel id")
                                let channel = Database.database().reference().child("channels").childByAutoId()
                                channel.setValue(["1":"1"])
                                userRef.child("contacts").child("\(self.schedules[indexPath.row].learnerID!)").updateChildValues(["channelid": channel.key])
                                otherUserRef.child("contacts").child("\(self.schedules[indexPath.row].tutorID!)").updateChildValues(["channelid": channel.key])
                                
                            }
                        })
                    }
                    }
                })
                
            }
        })
        
        userRef.child("schedules").updateChildValues(["\(schedules[indexPath.row].scheduleid)": true])
    }//end of function

}
