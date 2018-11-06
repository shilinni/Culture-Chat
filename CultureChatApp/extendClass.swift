//
//  extendClass.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 11/19/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension UIColor {
    static var pink : UIColor {
        return UIColor(red: 255/255.0, green: 91/255.0, blue: 166/255.0, alpha: 0.95)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension String {
    func firstLetter()->String?{
        return (self.isEmpty ? nil : self.substring(to: self.characters.index(after: self.startIndex)))
    }
}

struct Schedule{
    var learnerID : String?
    var tutorID : String?
    let language: String
    let userName: String?
    let time : String
    var learnerName: String
    var tutorName: String
    let scheduleid : String
    //let postByLearner : Bool
    let coin : Int?
}

struct MyRefs{
    static let databaseRoot = Database.database().reference()
    //static let databaseChats = databaseRoot.child("chats")
    static let channelRoot = databaseRoot.child("channels")
    static let userRoot = databaseRoot.child("users")
    static let scheduleRoot = databaseRoot.child("schedules")
}
