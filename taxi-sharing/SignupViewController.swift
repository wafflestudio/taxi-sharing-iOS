//
//  SignupViewController.swift
//  taxi-sharing
//
//  Created by 오승열 on 22/03/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit
import FirebaseAuth
import os.log

class SignupViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var guidanceLabel: UILabel!
    @IBOutlet weak var setNicknameButton: UIButton!
    let lengthLimit = 15
    var gender = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        femaleButton.layer.cornerRadius = 5
        maleButton.layer.cornerRadius = 5
        setNicknameButton.layer.cornerRadius = 5
        
        nicknameTextField.delegate = self
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "signupDoneSegue" {
            if (gender != "") && (nicknameTextField.text!.count > 0) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        if (string == " ") {
            return false
        }
        let newLength = text.count + string.count - range.length
        return newLength <= lengthLimit
    }
    
    //MAKR: IBActions
    @IBAction func femaleSignup(_ sender: UIButton) {
        if femaleButton.isSelected == false {
            if maleButton.isSelected == true {
                maleButton.isSelected = false
            }
            femaleButton.isSelected = true
            gender = "F"
        } else if femaleButton.isSelected == true {
            femaleButton.isSelected = false
            gender = ""
        } else {
            print("Error in selecting female for user's gender info.")
        }
        
    }
    
    @IBAction func maleSignup(_ sender: UIButton) {
        if maleButton.isSelected == false {
            if femaleButton.isSelected == true {
                femaleButton.isSelected = false
            }
            maleButton.isSelected = true
            gender = "M"
        } else if maleButton.isSelected == true {
            maleButton.isSelected = false
            gender = ""
        } else {
            print("Error in selecting male for user's gender info.")
        }
    }
    
    @IBAction func setNickname(_ sender: UIButton) {
        if gender == "" {
            guidanceLabel.text = "원활한 서비스 사용을 위해 성별 정보가 필요합니다."
            print("성별: \(gender)")
            return
        } else {
            if nicknameTextField.text != nil {
                if (nicknameTextField.text!.count == 0 )  {
                    guidanceLabel.text = "이름을 입력하지 않았습니다."
                } else if (0 < nicknameTextField.text!.count && nicknameTextField.text!.count <= 15 && gender != "") {
                    FirestoreManager().createUser(uid: Auth.auth().currentUser?.uid, gender: gender, isSNUMember: false, SNUmail: "None")
                    FirestoreManager().updateUser(uid: Auth.auth().currentUser?.uid, data: ["nickname": nicknameTextField.text!])
                    print("성별: \(gender)")
                    // self.performSegue(withIdentifier: "signupDoneSegue", sender: self)
                } else {
                    guidanceLabel.text = "이름은 공백없이 15자 이하만 가능합니다."
                }
            } else {
                print("nicknameTextField is nil")
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
