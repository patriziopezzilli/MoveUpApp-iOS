//
//  ServiceZone.swift
//  MoveUp
//
//  Created by MoveUp on 20/10/2025.
//

import Foundation
import CoreLocation

struct ServiceZone: Identifiable, Codable {
    let id: String
    var name: String
    var center: Coordinate
    var radiusInMeters: Double
    var isActive: Bool
    
    init(id: String = UUID().uuidString, name: String, center: Coordinate, radiusInMeters: Double, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.center = center
        self.radiusInMeters = radiusInMeters
        self.isActive = isActive
    }
    
    var radiusInKilometers: Double {
        radiusInMeters / 1000.0
    }
    
    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude)
    }
    
    // Verifica se una coordinata è dentro la zona
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = centerLocation.distance(from: targetLocation)
        return distance <= radiusInMeters
    }
    
    // Sample zones
    static let sampleZones: [ServiceZone] = [
        ServiceZone(
            name: "Milano Centro",
            center: Coordinate(latitude: 45.4642, longitude: 9.1900),
            radiusInMeters: 15000
        ),
        ServiceZone(
            name: "Milano Nord",
            center: Coordinate(latitude: 45.5200, longitude: 9.1700),
            radiusInMeters: 10000
        )
    ]
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    var clLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
