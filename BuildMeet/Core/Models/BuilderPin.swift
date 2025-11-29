//
//  BuilderPin.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import Foundation
import CoreLocation
import SwiftUI

struct BuilderPin: Identifiable, Equatable {
    let id = UUID()

    // UPDATED — split name into first & last
    var firstName: String
    var lastName: String

    // CONVENIENCE — full name everywhere
    var fullName: String { "\(firstName) \(lastName)" }

    var project: String
    var status: String
    var isUrgent: Bool
    var coordinate: CLLocationCoordinate2D

    // Equatable
    static func == (lhs: BuilderPin, rhs: BuilderPin) -> Bool {
        lhs.id == rhs.id
    }

    var statusColor: Color {
        switch status {
        case "Building": return .blue
        case "Stuck": return .orange
        case "Need Help": return .red
        case "Exploring": return .purple
        default: return .gray
        }
    }
}

