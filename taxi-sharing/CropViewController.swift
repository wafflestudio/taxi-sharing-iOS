//
//  CropViewController.swift
//  taxi-sharing
//
//  Created by 오승열 on 09/05/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit
import CropViewController

class CropViewController: TOCropViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    /*
    func presentCropViewController() {
        var image: UIImage? // Load an image
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController?, didCropToCircularImage image: UIImage?, with cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped, circular version of the original image
    }
 */
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
