//
//  SettingsViewController.swift
//  taxi-sharing
//
//  Created by 오승열 on 04/04/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var accountInfoView: UIView!
    @IBOutlet weak var accountSettingsView: UIView!
    @IBOutlet weak var appSettingsView: UIView!
    @IBOutlet weak var appInfoView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var noShowLabel: UILabel!
    @IBOutlet weak var isAuthenticatedLabel: UILabel!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let poonpoonColor = UIColor(red: 0.1294, green: 0.2039, blue: 0.3451, alpha: 1) /* #213458 */
        accountInfoView.layer.cornerRadius = 5
        accountInfoView.layer.borderColor = poonpoonColor.cgColor
        accountInfoView.layer.borderWidth = 2
        accountSettingsView.layer.cornerRadius = 5
        accountSettingsView.layer.borderColor = poonpoonColor.cgColor
        accountSettingsView.layer.borderWidth = 2
        appSettingsView.layer.cornerRadius = 5
        appSettingsView.layer.borderColor = poonpoonColor.cgColor
        appSettingsView.layer.borderWidth = 2
        appInfoView.layer.cornerRadius = 5
        appInfoView.layer.borderColor = poonpoonColor.cgColor
        appInfoView.layer.borderWidth = 2
        
        let userRef = db.collection("users").document((Auth.auth().currentUser?.uid)!)
        
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.userName.text = data?["nickname"] as? String
                let numberOfNoShow = data?["noShow"] as? Int
                self.noShowLabel.text = String(numberOfNoShow!)
                let isSNUMember = data?["isSNUMember"] as? Bool
                if isSNUMember == false {
                    self.isAuthenticatedLabel.text = "X"
                } else {
                    self.isAuthenticatedLabel.text = "O"
                }
            } else {
                fatalError("The user got into the application without having data in the firestore")
            }
        }
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        profilePicture.image = selectedImage
        
        // Create a reference to the picture file to be uploaded.
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("\(Auth.auth().currentUser?.uid)/\(FieldValue.serverTimestamp()).jpg")
        
        // Upload the file to the reference path
        guard let imageData = selectedImage.pngData() else {return}
        print(imageData)
        let uploadTask = profileImageRef.putData(imageData, metadata: nil) { metadata, error in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            /*
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
             storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
            } */
        }
        dismiss(animated: true, completion: nil)
        
        
    }
    
    //MARK: IBActions
    @IBAction func logoutAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "UserDistinguishViewController")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = initialViewController
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError)")
        } catch {
            print("Unknown error.")
        }
    }
    
    @IBAction func setProfileImage(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
        
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
