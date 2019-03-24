//
//  UserDistinguishViewController.swift
//  taxi-sharing
//
//  Created by 오승열 on 20/03/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit
import FirebaseAuth
import os.log

class UserDistinguishViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser != nil {
            print("뭐야뭐야: \(FirestoreManager().checkUser(uid: Auth.auth().currentUser?.uid))")
            switch FirestoreManager().checkUser(uid: Auth.auth().currentUser?.uid) {
                
            case true:
                self.performSegue(withIdentifier: "", sender: self)
            case false:
                if FirestoreManager().checkDriver(uid: Auth.auth().currentUser?.uid) {
                    self.performSegue(withIdentifier: "driverLoginSegue", sender: self)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Actions
    
    // IBAction function when loginPassenger button is clicked.
    @IBAction func loginPassenger(_ sender: UIButton) {
        self.performSegue(withIdentifier: "passengerLoginSegue", sender: self)
        
    }
    
    // IBAction function when loginDer button is clicked.
    @IBAction func loginDriver(_ sender: UIButton) {
        self.performSegue(withIdentifier: "driverLoginSegue", sender: self)
        
    }
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    

}
