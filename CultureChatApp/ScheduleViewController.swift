//
//  ScheduleViewController.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 11/19/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ScheduleViewController: UIViewController {

    @IBOutlet weak var languageName: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var student: UIButton!
    @IBOutlet weak var viewAll: UIButton!
    @IBOutlet weak var info: UIButton!
    @IBOutlet weak var skip: UIButton!
    @IBOutlet weak var tutor: UIButton!
    @IBOutlet weak var count: UILabel!
    
    var text : String?
    var firstTimeSchedule = false
    var learner : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        languageName.text=text
        skip.isHidden = !firstTimeSchedule
        count.layer.cornerRadius=count.frame.size.width/2
        count.layer.masksToBounds=true
        student.layer.cornerRadius=20
        //student.setTitleColor(UIColor.gray, for: .disabled)
        //student.setTitleColor(UIColor.white, for: .normal)
        
        let currentDate : NSDate = NSDate()
        let calendar : NSCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let component1: NSDateComponents = NSDateComponents()
        let component2: NSDateComponents = NSDateComponents()
        component1.hour = +1
        datePicker.minimumDate=calendar.date(byAdding: component1 as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))
        component2.month = +1
        datePicker.maximumDate=calendar.date(byAdding: component2 as DateComponents, to: currentDate as Date, options: NSCalendar.Options(rawValue: 0))
        datePicker.date = datePicker.minimumDate!
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
        userRef.child("schedules").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            self.count.text="\(snapshot.childrenCount)/3"
            
            if self.count.text=="3/3"{
                self.student.isEnabled=false
                self.student.backgroundColor=UIColor.lightGray
            }else{
                self.student.isEnabled=true
                self.student.backgroundColor=UIColor.pink
            }
        }
    }
    
    @IBAction func datePickerChanged(_ sender: Any) {
        
    }

    @IBAction func findAStudyMate(_sender: UIButton){
        var learnerid=""
        var tutorid=""
        if learner==true{
            learnerid="\(Auth.auth().currentUser!.uid)"
        }else{
            tutorid="\(Auth.auth().currentUser!.uid)"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let date = dateFormatter.string(from: datePicker.date)
        
        //alert
        let alert = UIAlertController.init(title: "", message: "Are you sure you want to schedule an appointment? You can at most have three appointments.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.scheduleAction(learnerid: learnerid, tutorid: tutorid, date: date)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func scheduleAction(learnerid: String, tutorid: String, date: String){
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
        let scheduleRef = Database.database().reference().child("schedules").childByAutoId()
        var learnerName = ""
        var tutorName = ""
        var userName = Auth.auth().currentUser!.displayName ?? "Anonymous"
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject] {
                let name = dict["username"]
                userName = "\(name!)"
                
                if learnerid == "" {
                    tutorName = userName
                }else{
                    learnerName = userName
                }
                //print("ob",userName,"1",tutorName,"2",learnerName)
                
                //print(userName,"1",tutorName,"2",learnerName)
                scheduleRef.setValue(["language": "\(self.languageName.text!)", "learner": learnerid,"tutor": tutorid, "time": "\(date)", "postByLearner": "\(self.learner!)", "username": userName, "learnerName": learnerName, "tutorName": tutorName])
                
                userRef.child("schedules").updateChildValues(["\(scheduleRef.key)": true])
                if self.learner==true{
                    userRef.child("learning").updateChildValues(["\(self.languageName.text!)": true])
                }else{
                    userRef.child("teaching").updateChildValues(["\(self.languageName.text!)": true])
                }

            }})

        
        
        var viewControllers = navigationController?.viewControllers
        viewControllers?.removeLast(1)
        navigationController?.setViewControllers(viewControllers!, animated: true)
    }
    /*@IBAction func studentClickAndSchedule(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let date = dateFormatter.string(from: datePicker.date)
        print(date)
        
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
        let scheduleRef = Database.database().reference().child("schedules").childByAutoId()
        scheduleRef.setValue(["language": "\(languageName.text!)", "learner": "\(Auth.auth().currentUser!.uid)","tutor": "", "time": "\(date)", "postByLearner": "true", "username": Auth.auth().currentUser!.displayName ?? "Anonymous"])
        userRef.child("schedules").updateChildValues(["\(scheduleRef.key)": true])
        userRef.child("learning").updateChildValues(["\(languageName.text!)": true])
    }
    @IBAction func viewAllAppoints(_ sender: UIButton) {
        
    }
    
    @IBAction func skipAndDone(_ sender: UIButton) {
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
        userRef.child("learning").updateChildValues(["\(languageName.text!)": true])
        
        var viewControllers = navigationController?.viewControllers
        viewControllers?.removeLast(2)
        navigationController?.setViewControllers(viewControllers!, animated: true)
    }
    @IBAction func TutorClickAndSchedule(_ sender: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        let date = dateFormatter.string(from: datePicker.date)
        print(date)
        
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
        let scheduleRef = Database.database().reference().child("schedules").childByAutoId()
        scheduleRef.setValue(["language": "\(languageName.text!)", "learner": "","tutor": "\(Auth.auth().currentUser!.uid)", "time": "\(date)", "postByLearner": "false", "username": Auth.auth().currentUser!.displayName ?? "Anonymous"])
        userRef.child("schedules").updateChildValues(["\(scheduleRef.key)": true])
        userRef.child("teaching").updateChildValues(["\(languageName.text!)": true])
        
    }*/
    @IBAction func getMoreInfo(_ sender: UIButton) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScheduleSegueA" || segue.identifier == "ScheduleSegueB" || segue.identifier == "ScheduleSegueC" {
            if let viewController = segue.destination as? PostSchdulesTableViewController {
                viewController.languageName=languageName.text!
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
