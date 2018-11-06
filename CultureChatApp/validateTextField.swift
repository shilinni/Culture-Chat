//
//  validateTextField.swift
//  CultureChatApp
//
//  Created by Shilin Ni on 11/18/17.
//  Copyright © 2017 Shilin Ni. All rights reserved.
//

import Foundation

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: .caseInsensitive)
        return (regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: characters.count)) != nil)
    }
}
