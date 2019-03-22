//
//  AskGenderViewController.swift
//  taxi-sharing
//
//  Created by 오승열 on 22/03/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit
import FirebaseAuth
import os.log

class AskGenderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MAKR: IBActions
    @IBAction func femaleSignup(_ sender: UIButton) {
        let uid = Auth.auth().currentUser!.uid
        FirestoreManager().createUser(uid: uid, gender: "F", isSNUMember: false, SNUmail: "None")
        self.performSegue(withIdentifier: "femaleLoginSegue", sender: self)
    }
    
    @IBAction func maleSignup(_ sender: UIButton) {
        let uid = Auth.auth().currentUser!.uid
        FirestoreManager().createUser(uid: uid, gender: "M", isSNUMember: false, SNUmail: "None")
        self.performSegue(withIdentifier: "maleLoginSegue", sender: self)
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
