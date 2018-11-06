//
//  ContactTableViewController.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 12/10/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct Contact{
    let id : String
    let profileImageData : Data?
    let name : String
}



class ContactTableViewController: UITableViewController {

    var contactList = [String]()
    var contacts = [String:[Contact]]()
    var contactLetters = [String]()
    
    required init? (coder decoder: NSCoder) {
        super.init(coder: decoder)
        //print("init")
        
        let userRef = Database.database().reference().child("users").child("\(Auth.auth().currentUser!.uid)").child("contacts")
        userRef.observe(.childAdded, with: { (snapshot) in
            self.contactList.append(snapshot.key)
            //print(snapshot.key)
            //let dict = snapshot.value as? [String: AnyObject]
            //let language = dict[""]
            let contactRef = Database.database().reference().child("users").child(snapshot.key)
            contactRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject]{
                    
                    let storageRef = Storage.storage().reference().child("\(snapshot.key).png")
                    
                    var data : Data?
                    storageRef.downloadURL(completion: { (url, error) in
                        if url == nil {

                        }else{
                            data = try? Data.init(contentsOf: url!)
                            //print("try data")
                        }
                        
                        //print("add aContact")
                        var name = "Anonymous"
                        if dict["username"] as! String != ""{
                            name = dict["username"] as! String
                        }
                        let aContact = Contact(id: snapshot.key, profileImageData: data, name: name)
                        let firstLetter=aContact.name.firstLetter()!
                        if self.contacts[firstLetter]?.append(aContact) == nil{
                            self.contacts[firstLetter]=[aContact]
                            
                            for value in self.contacts{
                                self.contacts[value.key]=value.value.sorted { $0.name<$1.name }
                            }
                            
                        }
                    })
                    
                    
                }})
            
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.contactLetters=Array(self.contacts.keys).sorted()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.contactLetters=Array(self.contacts.keys).sorted()
        //print("reload")
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return contactLetters.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let letter=contactLetters[section]
        return (contacts[letter]?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //print("letter ",contactLetters[0])
        //print("Name",contacts[contactLetters[0]]!)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCellIdentity") as! ContactTableViewCell

        cell.language.isHidden = true
        
        let letter=contactLetters[indexPath.section]
        let contactArray=contacts[letter]!
        let aContact = contactArray[indexPath.row]
        
        if let data = aContact.profileImageData{
            cell.profileImageView.image = UIImage(data: data)
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width / 2.0
            cell.profileImageView.layer.masksToBounds = true
        }else{
            //cell.profileImageView.image = UIImage(named: "")
        }
        cell.userName.text = aContact.name
        cell.uid = aContact.id
        
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactLetters[section]
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactLetters
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let destination = storyboard.instantiateViewController(withIdentifier: "SpecificContactStoryID") as! SpecificContactViewController
        let cell = tableView.cellForRow(at: indexPath) as! ContactTableViewCell

        destination.contactID = cell.uid
        destination.contactName = cell.userName.text!
        navigationController?.pushViewController(destination, animated: true)

    }

}
