//
//  MyThreeScheduleViewController.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 12/9/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class MyThreeScheduleViewController: UIViewController {

    @IBOutlet weak var View1: UIView!
    @IBOutlet weak var View2: UIView!
    @IBOutlet weak var View3: UIView!
    
    var viewsAnimated = [UIView]()
    var schedules = [Schedule]()
    var number = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //print("view did load")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //print("view will appear")

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print(number)
        //print("view did appear")
        
        View1.isHidden = true
        View2.isHidden = true
        View3.isHidden = true
        insertViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //print("view did disappear")
        
        for view in viewsAnimated{
            view.layer.position.y += 552
        }
        viewsAnimated=[UIView]()
        View1.isHidden = true
        View2.isHidden = true
        View3.isHidden = true
        number=0
        
        let uid = Auth.auth().currentUser!.uid
        let userRef = Database.database().reference().child("users").child("\(uid)").child("schedules")
        userRef.removeAllObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func insertViews (){
        let uid = Auth.auth().currentUser!.uid
        let userRef = Database.database().reference().child("users").child("\(uid)").child("schedules")
        //obse
        //username in post
        number = 0
        userRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                switch self.number {
                case 0:
                    //print("set Label for view1")
                    self.setLabels(forSchedule: snapshot.key, ofView: self.View1)
                case 1:
                    //print("set Label for view2")
                    self.setLabels(forSchedule: snapshot.key, ofView: self.View2)
                case 2:
                    //print("set Label for view3")
                    self.setLabels(forSchedule: snapshot.key, ofView: self.View3)
                default:
                    //print("default")
                    break
                }
                self.number += 1
            }
        })
    }
    
    func setLabels(forSchedule schedule: String, ofView view: UIView){
        let scheduleRef = Database.database().reference().child("schedules").child("\(schedule)")
        //print(schedule)
        scheduleRef.observeSingleEvent(of: .value, with: { (snapshot) in
             if let dict = snapshot.value as? [String: String?] {
                let aSchedule = Schedule(learnerID: dict["learner"]!! , tutorID: dict["tutor"]!!, language: dict["language"]!! , userName: dict["username"]!! , time: dict["time"]!! , learnerName: dict["learnerName"]!!,tutorName: dict["tutorName"]!!,scheduleid: snapshot.key, coin: 90)
                self.schedules.append(aSchedule)
                //print("setting")
                let uid = Auth.auth().currentUser!.uid
                if let name = view.viewWithTag(1) as? UILabel{
                    if aSchedule.learnerID == uid {
                        if aSchedule.tutorName == ""{
                            name.text = "Anonymous"
                        }else{
                            name.text = aSchedule.tutorName
                        }
                        
                        if aSchedule.tutorID == ""{
                            name.text = "No tutor"
                        }
                    }else{
                        name.text = aSchedule.learnerName
                        if aSchedule.learnerID == ""{
                            name.text = "No learner"
                        }
                    }
                }
                if let time = view.viewWithTag(2) as? UILabel {
                    time.text = aSchedule.time
                }
                if let language = view.viewWithTag(3) as? UILabel {
                    language.text = aSchedule.language
                }
                self.animateViews(view: view)
            }//end of dict
            
        })//end of observe
    }   // end of function

    func animateViews (view: UIView){
        //print(view.tag)
        view.isHidden=false
        self.viewsAnimated.append(view)
        UIView.animate(withDuration: 4.0, delay: Double(view.tag) - 10.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0, options: [], animations: {
            view.layer.position.y -= 552
            view.layer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        }, completion: nil)
    }
}
