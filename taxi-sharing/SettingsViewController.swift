//
//  SettingsViewController.swift
//  taxi-sharing
//
//  Created by 오승열 on 04/04/2019. Used Tim Oliver's TOCropViewController.
//  See https://github.com/TimOliver/TOCropViewController for more information.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import CropViewController
import FirebaseUI
import FirebaseStorage

class SettingsViewController: UIViewController, CropViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

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
    
    private let imageView = UIImageView()
    
    private var image: UIImage?
    private var croppingStyle = CropViewCroppingStyle.default
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    private let lengthLimit = 15
    
    //MARK: Overriding View Related Functions
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
                
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let imageRef = storageRef.child("profileimages/\((Auth.auth().currentUser?.uid)!).jpeg")
                let placeholderImage = UIImage(named: "Profile")
                self.profilePicture.sd_setImage(with: imageRef, placeholderImage: placeholderImage)
                
            } else {
                fatalError("The user got into the application without having data in the firestore")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
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
        
        let alertController = UIAlertController(title: nil, message: "프로필 이미지 변경", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "기본 이미지로 변경", style: .default) { (action) in
            
            SDImageCache.shared().clearMemory()
            SDImageCache.shared().clearDisk(onCompletion: nil)
            FirestoreManager().deleteImage()
            self.profilePicture.image = UIImage(named: "Profile") ?? UIImage()
            self.showToast(message: "기본 이미지로 변경되었습니다.")
        }
        
        let profileAction = UIAlertAction(title: "앨범에서 선택", style: .default) { (action) in
            self.croppingStyle = .circular
            
            let imagePicker = UIImagePickerController()
            imagePicker.modalPresentationStyle = .popover
            imagePicker.preferredContentSize = CGSize(width: 320, height: 568)
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
            // canceling the action
        }
        
        alertController.addAction(defaultAction)
        alertController.addAction(profileAction)
        alertController.addAction(cancelAction)
        alertController.modalPresentationStyle = .popover
        
        
        let presentationController = alertController.popoverPresentationController
        presentationController?.sourceView = sender
        presentationController?.sourceRect = sender.bounds
        presentationController?.permittedArrowDirections = UIPopoverArrowDirection.left
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    //MARK: Functions
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: croppingStyle, image: image)
        cropController.delegate = self
        
        self.image = image
        
        //If profile picture, push onto the same navigation stack
        if croppingStyle == .circular {
            if picker.sourceType == .camera {
                picker.dismiss(animated: true, completion: {
                    self.present(cropController, animated: true, completion: nil)
                })
            } else {
                picker.pushViewController(cropController, animated: true)
            }
        }
        else { //otherwise dismiss, and then present from the main controller
            picker.dismiss(animated: true, completion: {
                self.present(cropController, animated: true, completion: nil)
                //self.navigationController!.pushViewController(cropController, animated: true)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk(onCompletion: nil)
        FirestoreManager().uploadImage(image: image)
        self.profilePicture.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Resetting username
    @IBAction func resetUsername(_ sender: Any) {
        let alertController = UIAlertController(title: "사용자 이름 변경", message: nil, preferredStyle: .alert)
        
        let resetAction = UIAlertAction(title: "변경", style: .default) { (_) in
            let usernameTextField = alertController.textFields![0] as UITextField
            FirestoreManager().updateUser(uid: Auth.auth().currentUser?.uid, data: ["nickname": usernameTextField.text!])
            self.userName.text = usernameTextField.text
            self.showToast(message: "사용자 이름이 변경되었습니다.")
        }
        resetAction.isEnabled = false
        alertController.addAction(resetAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (_) in
            //
        }
        alertController.addAction(cancelAction)
        
        alertController.addTextField{ (textField) in
            textField.placeholder = "사용자 이름 : 15자 이하"
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                resetAction.isEnabled = ((textField.text! != "") && (textField.text!.count <= 15))
            }
        }
        
        present(alertController, animated: true)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the selected object to the new view controller.
    }
    */
}
