//
//  LanguageSelectionViewController.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 11/19/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LanguageSelectionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var pickerData = [String]()
    var row = 0
    var selectedSegmentIsLearning=true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.picker.delegate = self
        self.picker.dataSource = self
        pickerData = ["English", "Spanish", "French", "Japanese", "Korean", "Russian", "Chinese", "German"]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    //CHANGED!  Done button
    @IBAction func goToNextStep(_ sender: Any) {
        /*let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "RegularScheduleIdentifier") as! ScheduleViewController
        destination.firstTimeSchedule=true
        destination.text=pickerData[picker.selectedRow(inComponent: 0)]
        navigationController?.pushViewController(destination, animated: true)*/
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
        if selectedSegmentIsLearning {
            userRef.child("learning").updateChildValues(["\(pickerData[picker.selectedRow(inComponent: 0)])": true])
        }
        else{
            userRef.child("teaching").updateChildValues(["\(pickerData[picker.selectedRow(inComponent: 0)])": true])
        }
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelAndGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func switchSegments(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            selectedSegmentIsLearning=true
        case 1:
            selectedSegmentIsLearning=false
        default:
            break; 
        }
    }
    


}
