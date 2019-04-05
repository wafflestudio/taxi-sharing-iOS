//
//  RoomListViewController.swift
//  taxi-sharing
//
//  Created by 오승열 on 12/02/2019.
//  Copyright © 2019 CroonSSS. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class RoomListViewController: UITableViewController, MTMapViewDelegate, CLLocationManagerDelegate {

    //MARK: Properties
    lazy var floatingActionButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0.1294, green: 0.2039, blue: 0.3451, alpha: 1) /* #213458 */
        button.addTarget(self, action: #selector(floatingActionButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    let locationManager = CLLocationManager()
    
    //MARK: Overriding View Related Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request user's authorization for using location info when in use and in the background.
        locationManager.requestAlwaysAuthorization()
        
        // Get user's location info
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let superview = UIApplication.shared.keyWindow {
            superview.addSubview(floatingActionButton)
            setupButton()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let superview = UIApplication.shared.keyWindow, floatingActionButton.isDescendant(of: superview) {
            floatingActionButton.removeFromSuperview()
        }
    }
    
    
    //MARK: Functions
    
    // Calls askAgainForLocation if user's status is "denied".
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            askAgainForLocation()
        }
    }
    
    // Show the popup to the user if we have been deined access
    func askAgainForLocation() {
        let alertController = UIAlertController(title: "위치 정보 접근이 거부된 상태입니다.",
                                                message: "원활한 서비스 이용을 위해 위치 정보 접근 동의가 필요합니다.",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "설정", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setupButton() {
        let img = UIImage(named: "PlusIcon")
        NSLayoutConstraint.activate([
            floatingActionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            floatingActionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -108),
            floatingActionButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            floatingActionButton.heightAnchor.constraint(equalToConstant: 50),
            floatingActionButton.widthAnchor.constraint(equalToConstant: 50)
            ])
        floatingActionButton.setImage(img, for: .normal)
        floatingActionButton.layer.cornerRadius = 25
        floatingActionButton.layer.masksToBounds = true
    }
    
    @objc func floatingActionButtonTapped(_ button: UIButton) {
        var mapView: MTMapView?
        mapView = MTMapView(frame: self.view.bounds)
        if let mapView = mapView {
            mapView.delegate = self
            mapView.baseMapType = .standard
            self.view.addSubview(mapView)
        }
        print("The floating action button is tapped.")
    }
    
    func mtMapView(_ mapView: MTMapView?, updateCurrentLocation location: MTMapPoint?, with accuracy: MTMapLocationAccuracy) {
        let currentLocationPointGeo: MTMapPointGeo? = location?.mapPointGeo()
        if let latitude = currentLocationPointGeo?.latitude, let longitude = currentLocationPointGeo?.longitude {
            print("MTMapView updateCurrentLocation (\(latitude),\(longitude)) accuracy (\(accuracy))")
        }
    }
}

