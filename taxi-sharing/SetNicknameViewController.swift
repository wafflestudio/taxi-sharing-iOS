//
//  SetNicknameViewController.swift
//  taxi-sharing
//
//  Created by 오승열 on 23/03/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit
import FirebaseAuth

class SetNicknameViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var guidanceLabel: UILabel!
    @IBOutlet weak var setNicknameButton: UIButton!
    let lengthLimit = 15
    var gender = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setNicknameButton.isEnabled = false

        // Handle the text field’s user input through delegate callbacks.
        nicknameTextField.delegate = self
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.checkField(sender: self)
    }
    
    //MARK: Private Functions
    private func checkField(sender: AnyObject) {
        if (nicknameTextField.text?.isEmpty)! {
            setNicknameButton.isEnabled = false
        } else {
            setNicknameButton.isEnabled = true
        }
    }
    
    //MARK: Actions
    @IBAction func setNickname(_ sender: UIButton) {
        
        if nicknameTextField.text != nil {
            if (nicknameTextField.text!.count == 0 )  {
                guidanceLabel.text = "이름을 입력하지 않았습니다."
            } else if (0 < nicknameTextField.text!.count && nicknameTextField.text!.count <= 15) {
                FirestoreManager().createUser(uid: Auth.auth().currentUser?.uid, gender: gender, isSNUMember: false, SNUmail: "None")
                FirestoreManager().updateUser(uid: Auth.auth().currentUser?.uid, data: ["nickname": nicknameTextField.text!])
                self.performSegue(withIdentifier: "nicknameLoginSegue", sender: self)
            } else {
                guidanceLabel.text = "이름은 공백없이 15자 이하만 가능합니다."
            }
        } else {
            print("nicknameTextField is nil")
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
