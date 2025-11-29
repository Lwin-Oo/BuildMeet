//
//  DragAndDropPinViewModel.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/28/25.
//

import SwiftUI
import MapKit
import Foundation
import Combine
import CoreLocation

class DragAndDropPinViewModel: ObservableObject {
    @Published var isDragging = false
    @Published var showFloatingPin = false
    @Published var dragPosition: CGPoint = .zero
    
    // User current location
    @Published var userCoordinate: CLLocationCoordinate2D?
    
    // Free tier radius (25 km)
    let freeRadius: Double = 25000  // meters
}

