//
//  FirestoreManager.swift
//  taxi-sharing
//
//  Created by 오승열 on 22/03/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirestoreManager {
    
    //MARK: Properties
    let db = Firestore.firestore()
   
    
    //MARK: Initializers
    init() {}
    
    
    //MARK: Functions

    // Adds user to Cloud Firestore
    func createUser(uid: String?, gender: String?, isSNUMember: Bool?, SNUmail: String?) {
        db.collection("users").document(uid!).setData([
            "userID": uid!,
            "nickname": "",
            "gender": gender!,
            "isSNUMember": isSNUMember!,
            "SNUmail": SNUmail!,
            "createdDate": FieldValue.serverTimestamp(),
            "lastLoginDate": FieldValue.serverTimestamp(),
            "noShow": 0,
            "noPay": 0,
            "currentRoom": "None"
        ]) {err in
            if let err = err {
                print("Error writing users document: \(err)")
            } else {
                print("Users document is successfully written")
            }
        }
    }
    
    // Updates a user's document
    func updateUser(uid: String?, data: [String: Any]) {
        db.collection("users").document(uid!).updateData(data) {err in
            if let err = err {
                print("Error updating \(uid!)'s document: \(err)")
            } else {
                print("\(uid!)'s document was successfully updated")
            }
        }
    }
    
    // Checks if a user exists in Cloud Firestore
    func checkUser(uid: String?) -> Bool {
        let userRef = db.collection("users").document(uid!)
        var result = false
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("The user's document does exist.")
                result = true
            } else {
                print("The user's document does not exist: \(String(describing: error))")
                result = false
            }
        }
        return result
    }
    
    // Updates a user's login log
    func updateLogin(uid: String?) {
        db.collection("users").document(uid!).updateData([
            "lastLoginDate": FieldValue.serverTimestamp()
        ]) {err in
            if let err = err {
                print("Error updating \(uid!)'s lastLoginDate: \(err)")
            } else {
                print("\(uid!)'s lastLoginDate was successfully updated")
            }
        }
    }
    
    // Adds driver to Cloud Firestore
    func createDriver(uid:String?, name: String, number: String) {
        db.collection("drivers").document(uid!).setData([
            "userID": uid!,
            "name": name,
            "number": number,
            "isVerified": false,
            "currentRoom": "None"
        ]) {err in
            if let err = err {
                print("Error writing drivers document: \(err)")
            } else {
                print("Drivers document is successfully written")
            }
        }
    }
    
    // Updates a driver's document
    func updateDriver(uid: String?, data: [String: Any]) {
        db.collection("drivers").document(uid!).updateData(data) {err in
            if let err = err {
                print("Error updating driver \(uid!)'s document: \(err)")
            } else {
                print("Driver \(uid!)'s document was successfully updated")
            }
        }
    }
    
    // Checks if a user exists in Cloud Firestore
    func checkDriver(uid: String?) -> Bool {
        var result = false
        let userRef = db.collection("drivers").document(uid!)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                print("The driver's document does exist.")
                result = true
            } else {
                print("The driver's document does not exist.")
                result = false
            }
        }
        
        return result
    }
    
    // Adds room to Cloud Firestore
    func createRoom(name: String?, departure: String?, departureCoordinate: String?, destination: String?, owner: String?, isGenderLimit: Bool?, startCondition: String?, startSpecificCondition: Int?) {
        let newRoomRef = db.collection("rooms").document()
        
        newRoomRef.setData([
            "name": name!,
            "createdDate": FieldValue.serverTimestamp(),
            "departure": departure!,
            "departureCoordinate": departureCoordinate!,
            "destination": destination!,
            "isGenderLimit": isGenderLimit!,
            "startCondition": startCondition!,
            "startSpecificCondition": startSpecificCondition!,
            "endedDate": "Not ended",
            "numberOfMembers": 1
        ]) {err in
            if let err = err {
                print("Error creating a room document: \(err)")
            } else {
                print("Room document is successfully written")
            }
        }
        newRoomRef.collection("members").document("owner").setData([
            "userID": owner!,
            "isMember": true
        ]) {err in
            if let err = err {
                print("Error adding the room owner's information in the subcollection 'members' of the room: \(err)")
            } else {
                print("Room owner's information is successfully written.")
            }
        }
        
        updateUser(uid: owner!, data: ["currentRoom": newRoomRef.documentID])
    }
    
    // Update a room's document
    func updateRoom(roomID: String?, data: [String: Any]) {
        db.collection("rooms").document(roomID!).updateData(data) {err in
            if let err = err {
                print("Error updating room \(roomID!)'s document: \(err)")
            } else {
                print("Room \(roomID!)'s document was successfully updated")
            }
        }
    }
    
    // Add message document in the subcollection "messages" of a room
    func addMessage(roomID: String?, from: String?, content: String?) {
        let docRef = db.collection("rooms").document(roomID!).collection("members").document(from!)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                fatalError("User \(from!) tried to add message to the database after quitting the room.")
            }
        }
        
        let newMessage = db.collection("rooms").document(roomID!).collection("messages").document()
        newMessage.setData([
            "from": from!,
            "content": content!,
            "timestamp": FieldValue.serverTimestamp()
        ]) {err in
            if let err = err {
                print("Error adding message to room \(roomID!): \(err)")
            } else {
                print("New message is successfully written in the subcollection of room \(roomID!)")
            }
        }
    }
    
    // Adds the new member to the room's member list.
    func joinRoom(roomID: String?, uid: String?) {
        db.collection("rooms").document(roomID!).collection("members").document(uid!).setData([
            "userID": uid!,
            "isMember": true
        ]) {err in
            if let err = err {
                print("Error adding user \(uid!) to room \(roomID!): \(err)")
            } else {
                print("User \(uid!) is successfully added as a member of room \(roomID!)")
            }
        }
        
        updateUser(uid: uid!, data: ["currentRoom": roomID!])
        
        let roomRef = db.collection("rooms").document(roomID!)
        roomRef.getDocument {(document, error) in
            if let document = document, document.exists {
                let docData = document.data()
                let numberOfMembers = docData!["numberOfMembers"] as? Int ?? 1
                self.updateRoom(roomID: roomID!, data: ["numberOfMembers": numberOfMembers + 1])
            } else {
                print("Document does not exist")
            }
        
        }
    }
    
    // Set isMember to false for the user who quits the room.
    func quitRoom(roomID: String?, uid: String?) {
        db.collection("rooms").document(roomID!).collection("members").document(uid!).setData([
            "isMember": false
        ]) {err in
            if let err = err {
                print("Error quitting user \(uid!) from room \(roomID!): \(err)")
            } else {
                print("User \(uid!) is successfully quitted from room \(roomID!)")
            }
        }
        
        updateUser(uid: uid!, data: ["currentRoom": "None"])
        
        let roomRef = db.collection("rooms").document(roomID!)
        roomRef.getDocument {(document, error) in
            if let document = document, document.exists {
                let docData = document.data()
                let numberOfMembers = docData!["numberOfMembers"] as? Int ?? 1
                self.updateRoom(roomID: roomID!, data: ["numberOfMembers": (numberOfMembers - 1)])
            } else {
                print("Document does not exist")
            }
        }
    }
}
