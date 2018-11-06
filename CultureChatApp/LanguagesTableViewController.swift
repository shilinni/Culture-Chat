//
//  LanguagesTableViewController.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 11/18/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

struct Language {
    let uid: String
    let languageName: String
}
class LanguagesTableViewController: UITableViewController {

    var learning = [String]()
    var teaching = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //edit button
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
        userRef.child("learning").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Bool] {
                self.learning=[String]()
                for key in dict.keys{
                    self.learning.append(key)
                    //print(2)
                    self.tableView.reloadData()
                }
            }
        }
        userRef.child("teaching").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if let dict = snapshot.value as? [String: Bool] {
                self.teaching=[String]()
                for key in dict.keys{
                    self.teaching.append(key)
                    self.tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.learning.count
        }
        return self.teaching.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Learning"
        }
        return "Teaching"
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as! MenuTableViewCell
        if indexPath.section == 0{
            cell.myLabel.text = self.learning[indexPath.row]
        }else{
            cell.myLabel.text = self.teaching[indexPath.row]
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "AllSchedules") as! PostSchdulesTableViewController
        let cell = tableView.cellForRow(at: indexPath) as! MenuTableViewCell
        //navigationController?.title = cell.myLabel.text
        destination.languageName=cell.myLabel.text!
        if indexPath.section==0{
            destination.status="learner"
        }else{
            destination.status="tutor"
        }
        navigationController?.pushViewController(destination, animated: true)
    }

    //edit the table view
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to remove this language from your menu?", preferredStyle: .alert)
            
            //delete Action
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in

                let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)")
                let cell=tableView.cellForRow(at: indexPath) as! MenuTableViewCell
                let languageName=cell.myLabel.text!
                var sectionName="learning"
                if indexPath.section == 1 {
                    sectionName="teaching"
                }
                //remove child from database & table
                userRef.child("\(sectionName)").child("\(languageName)").removeValue(completionBlock: { (error, _) in
                    
                    if error != nil {
                        print(error!)
                    }
                    else{
                        if sectionName=="learning"{
                            self.learning.remove(at: indexPath.row)
                            //print(1)
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                        else{
                            self.teaching.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                })
                
            })
            alertController.addAction(deleteAction)
            
            //cancel Action
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
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
