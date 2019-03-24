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
    
    //MARK: Properties
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    var gender = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        femaleButton.layer.cornerRadius = 5
        maleButton.layer.cornerRadius = 5
    }
    
    //MAKR: IBActions
    @IBAction func femaleSignup(_ sender: UIButton) {
        gender = "F"
        self.performSegue(withIdentifier: "femaleSignupSegue", sender: self)
    }
    
    @IBAction func maleSignup(_ sender: UIButton) {
        gender = "M"
        self.performSegue(withIdentifier: "maleSignupSegue", sender: self)
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the user is authenticated
        guard Auth.auth().currentUser != nil else {
            os_log("The user is not logged in, cancelling.", log: OSLog.default, type: .debug)
            return
        }
        if segue.destination is SetNicknameViewController {
            let vc = segue.destination as? SetNicknameViewController
            vc?.gender = gender
        }
    }
    

}
