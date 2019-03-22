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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            if KOSession.shared().isOpen() {
                KOSessionTask.userMeTask(completion: { (error, me) in if let error = error as Error? {
                    print("Error in getting user information through KOSessionTask.userMeTask: \(error)")
                } else if let me = me as KOUserMe? {
                    self.requestFirebaseToken(userID: "iOSKakao" + me.id!)
                } else {
                    print("has no id")
                    }
                })
                os_log("login succeeded.", log: OSLog.default, type: .debug)
            }
        } else {
            self.performSegue(withIdentifier: "loginSegue", sender: self)
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
                    self.requestFirebaseToken(userID: "iOSKakao" + me.id!)
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
    
    /* Receives Firebase custom token from the server, and then log in into firebase authentication.
     These codes are copied from https://github.com/FirebaseExtended/custom-auth-samples. Minor changes added to the original source.
    */
    func requestFirebaseToken(userID: String) {
        
        let url = URL(string: String(format: "%@/verifyToken", Bundle.main.object(forInfoDictionaryKey: "VALIDATION_SERVER_URL") as! String))!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let parameters: [String: String] = ["userID": userID]
        
        do {
            let jsonParams = try JSONSerialization.data(withJSONObject: parameters, options: [])
            urlRequest.httpBody = jsonParams
        } catch {
            print("Error in adding token as a parameter: \(error)")
        }
        
        let signInTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error in request token verifying: \(error!)")
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as! [String: String]
                let firebaseToken = jsonResponse["firebase_token"]!
                self.signInToFirebaseWithToken(firebaseToken: firebaseToken, userID: userID)
                
            } catch let error {
                print("Error in parsing token: \(error)")
            }
            }
        signInTask.resume()
    }
    
    /**
     Sign in to Firebse with the custom token generated from the validation server.
     
     Performs segue if signed in successfully.
     
     These codes are also from https://github.com/FirebaseExtended/custom-auth-samples.
     */
    func signInToFirebaseWithToken(firebaseToken: String, userID: String) {
        Auth.auth().signIn(withCustomToken: firebaseToken) { (user, error) in
            if let authError = error {
                print("Error in authenticating with Firebase custom token: \(authError)")
            } else {
                if FirestoreManager().checkUser(uid: userID) {
                    FirestoreManager().updateLogin(uid: userID)
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
                } else {
                    self.performSegue(withIdentifier: "signupSegue", sender: self)
                }
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the user is authenticated
        guard Auth.auth().currentUser != nil else {
            os_log("The user is not logged in, cancelling.", log: OSLog.default, type: .debug)
            return
        }
    }
}
