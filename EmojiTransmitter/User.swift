//
//  User.swift
//  EmojiTransmitter
//
//  Created by Sanchit Garg on 15/10/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation

class User: Hashable {
  
  var id: String?
  var email: String
  var name: String
  
  init(name: String, email: String) {
    self.name = name
    self.email = email
  }
  
  //Plain == make a bot!
  init() {
    self.email = "nil"
    self.name = "Bot"
  }

  
  var hashValue: Int {
    return email.hashValue
  }
  
  static func == (lhs: User, rhs: User) -> Bool {
    return lhs.email == rhs.email
  }
  
}
