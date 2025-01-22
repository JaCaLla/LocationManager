//
//  LocationManager.swift
//  SMOC
//
//  Created by Javier Calatrava on 16/1/25.
//

import Foundation
import CoreLocation

@globalActor
actor GlobalManager {
    static var shared = GlobalManager()
}

@GlobalManager
class LocationManager: NSObject, ObservableObject  {
    private var clLocationManager: CLLocationManager? = nil

    @MainActor
    @Published var permissionGranted: Bool = false
    private var internalPermissionGranted: Bool = false {
         didSet {
            Task { [internalPermissionGranted] in
                await MainActor.run {
                    self.permissionGranted = internalPermissionGranted
                }
            }
        }
    }
    
    @MainActor
    @Published var speed: Double = 0.0
    private var internalSpeed: Double = 0.0 {
         didSet {
            Task { [internalSpeed] in
                await MainActor.run {
                    self.speed = internalSpeed
                }
            }
        }
    }
    
    init(clLocationManager: CLLocationManager = CLLocationManager()) {
        super.init()
        self.clLocationManager = clLocationManager
        clLocationManager.delegate = self
    }
    
    func checkPermission() {
        clLocationManager?.requestWhenInUseAuthorization()
    }
}

extension LocationManager: @preconcurrency CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let statuses: [CLAuthorizationStatus] = [.authorizedWhenInUse, .authorizedAlways]
        if statuses.contains(status) {
            internalPermissionGranted = true
            Task {
                internalStartUpdatingLocation()
            }
        } else if status == .notDetermined {
            checkPermission()
        } else {
            internalPermissionGranted = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        internalSpeed = location.speed
    }
    
    private func internalStartUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        clLocationManager?.startUpdatingLocation()
    }
}
