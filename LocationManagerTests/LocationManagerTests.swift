//
//  LocationManagerTests.swift
//  LocationManagerTests
//
//  Created by Javier Calatrava on 21/1/25.
//

import CoreLocation
import Testing
@testable import LocationManager

struct ManagersTestTests {
    
 
    @Test func testAthorizacionRequestDenied() async throws {
        let locationManagerMock = LocationManagerMock()
        locationManagerMock.clAuthorizationStatus = .denied
        let sut = await LocationManager(clLocationManager: locationManagerMock)
        await sut.checkPermission()
        // Wait for the @Published speed property to update
        try await Task.sleep(nanoseconds: 1_000_000)
        await #expect(sut.permissionGranted == false)
    }


    @Test func testAthorizacionRequestAuthorized() async throws {
        let locationManagerMock = LocationManagerMock()
        locationManagerMock.clAuthorizationStatus =  .authorizedWhenInUse
        let sut = await LocationManager(clLocationManager: locationManagerMock)
        await sut.checkPermission()
        // Wait for the @Published speed property to update
        try await Task.sleep(nanoseconds: 1_000_000)
        await #expect(sut.permissionGranted == true)
    }
    

    @Test func testStartUpdatingLocation() async throws {
        let locationManagerMock = LocationManagerMock()
        locationManagerMock.clAuthorizationStatus =  .authorizedWhenInUse
        let sut = await LocationManager(clLocationManager: locationManagerMock)
        await sut.checkPermission()
        // Wait for the @Published speed property to update
        try await Task.sleep(nanoseconds: 50_000_000)
               
        await #expect(sut.speed == 10.00)
    }
}

class LocationManagerMock: CLLocationManager {
    var clAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override func requestWhenInUseAuthorization() {
        delegate?.locationManager!(self, didChangeAuthorization: clAuthorizationStatus)
    }
    
    override func startUpdatingLocation() {
        let sampleLocation = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            altitude: 10.0,
            horizontalAccuracy: 5.0,
            verticalAccuracy: 5.0,
            course: 90.0,
            speed: 10.0,
            timestamp: Date()
        )
        delegate?.locationManager!(self, didUpdateLocations: [sampleLocation])
    }
}
