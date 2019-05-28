//
//  User.swift
//  TodoFirebase
//
//  Created by Дмитрий Ага on 5/29/19.
//  Copyright © 2019 Дмитрий Ага. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    
    init (user: Firebase.User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
