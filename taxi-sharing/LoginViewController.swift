//
//  LoginViewController.swift
//  taxi-sharing
//
//  Created by 오승열 on 15/03/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit
import os.log
import FirebaseAuth

class LoginViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var kakaoLoginButton: KOLoginButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.kakaoLoginButton.isEnabled == false {
            self.kakaoLoginButton.isEnabled = true
        }
        
        Auth.auth().addStateDidChangeListener() {auth, user in
            if user != nil {
                FirestoreManager().checkUser(uid: user?.uid) {(success) in
                    if success == true {
                        self.performSegue(withIdentifier: "loginSegue", sender: self)
                    } else if success == false {
                        self.performSegue(withIdentifier: "signupSegue", sender: self)
                    } else {
                        fatalError("Fatal error in LoginViewController. The user could not either log in or sign up.")
                    }
                }
            }
        }
    }
    
    //MARK: Actions
    
    // IBAction function when loginKakao button is clicked.
    @IBAction func loginKakao(_ sender: UIButton) {
        
        guard let session = KOSession.shared() else {return}
        if session.isOpen() {
            session.close()
        }
        session.open(completionHandler: {(error) in
            if session.isOpen() {
                KOSessionTask.userMeTask(completion: { (error, me) in if let error = error as Error? {
                    print("Error in getting user information through KOSessionTask.userMeTask: \(error)")
                } else if let me = me as KOUserMe? {
                    FirestoreManager().requestFirebaseToken(userID: "iOSKakao" + me.id!)
                } else {
                    print("has no id")
                    }
                })
                os_log("login succeeded.", log: OSLog.default, type: .debug)
            } else {
                os_log("login failed", log: OSLog.default, type: .error)
            }
        })
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the user is authenticated
        guard Auth.auth().currentUser != nil else {
            os_log("The user is not logged in, cancelling.", log: OSLog.default, type: .debug)
            return
        }
        
        switch(segue.identifier ?? "") {
        case "loginSegue":
            os_log("Existing user logging in.", log: OSLog.default, type: .debug)
            
        case "signupSegue":
            guard segue.destination is SignupViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if Auth.auth().currentUser == nil {
            return false
        } else {
            return true
        }
    }
}
