//
//  File.swift
//  LoginModel
//
//  Created by MAC on 2017. 6. 23..
//  Copyright © 2017년 kcs. All rights reserved.
//
import Foundation
import Firebase

struct UserInfo {
    var kakaouser: KOUserMe
    var name: String
    var email: String
    var id: String
    var password: String
    var joinAddress: String
    
    init(kakaouser: KOUserMe? ,name: String?, email: String?, id: String?, password: String?, joinAddress: String?){
        self.kakaouser = kakaouser!
        self.name = name!
        self.email = email!
        self.id = id!
        self.password = password!
        self.joinAddress = joinAddress!
        
    }
    
    init(){
        self.kakaouser = KOUserMe.init()
        self.name = ""
        self.email = ""
        self.id = ""
        self.password  = ""
        self.joinAddress  = ""
        
    }
}
