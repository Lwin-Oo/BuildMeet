//
//  UserProfile.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import Foundation
import CoreLocation

struct UserProfile: Identifiable, Codable {
    let id: UUID
    var name: String
    var bio: String
    var project: String
    var status: String
    var xp: Int
    var level: Int

    // Store coordinates manually (Codable-friendly)
    var latitude: Double?
    var longitude: Double?

    var coordinate: CLLocationCoordinate2D? {
        get {
            if let lat = latitude, let lon = longitude {
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            return nil
        }
        set {
            latitude = newValue?.latitude
            longitude = newValue?.longitude
        }
    }

    init(
        id: UUID = UUID(),
        name: String,
        bio: String,
        project: String,
        status: String,
        xp: Int = 0,
        level: Int = 1,
        coordinate: CLLocationCoordinate2D? = nil
    ) {
        self.id = id
        self.name = name
        self.bio = bio
               self.project = project
        self.status = status
        self.xp = xp
        self.level = level

        // Save coordinate parts
        self.latitude = coordinate?.latitude
        self.longitude = coordinate?.longitude
    }
}

