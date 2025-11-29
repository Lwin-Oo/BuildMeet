//
//  EventPin.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import Foundation
import CoreLocation
import SwiftUI

struct EventPin: Identifiable {
    let id = UUID()
    let title: String
    let host: String
    let description: String
    let isUrgent: Bool
    let coordinate: CLLocationCoordinate2D

    var color: Color {
        isUrgent ? .red : .orange
    }
}

