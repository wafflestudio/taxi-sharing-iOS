//
//  CropViewController.swift
//  taxi-sharing
//
//  Created by 오승열 on 09/05/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit

class CropViewController: TOCrop {
    func presentCropViewController() {
        var image: UIImage? // Load an image
        let cropViewController = CropViewController(croppingStyle: .circular, image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController?, didCropToCircularImage image: UIImage?, with cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped, circular version of the original image
    }

}
