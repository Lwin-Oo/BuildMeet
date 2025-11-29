//
//  MapViewModel.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import Foundation
import CoreLocation
import MapKit
import Combine

class MapViewModel: ObservableObject {

    // 🌍 Visible region (if you ever decide to control it again)
    @Published var region = MKCoordinateRegion()

    // 🎯 Free radius in METERS (used for monetization + drop checks)
    // Example: 25_000 = 25 km
    @Published var freeRadius: Double = 25_000

    // 👤 Logged-in user's map pin
    @Published var currentUser: BuilderPin?

    // 🛠 Builders
    @Published var builders: [BuilderPin] = []
    @Published var selectedBuilder: BuilderPin? = nil

    // 🎉 Events
    @Published var events: [EventPin] = []

    // Toggle between people vs events
    @Published var showPeople: Bool = true

    private var locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Default region (SF)
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.045, longitudeDelta: 0.045)
        )

        setupSubscribers()
        locationService.requestPermission()

        loadCurrentUser()
        loadMockBuilders()
        loadMockEvents()
    }

    // MARK: - LOCATION UPDATES
    private func setupSubscribers() {
        locationService.$userLocation
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                guard let self = self else { return }

                // update currentUser coordinate live
                if var user = self.currentUser {
                    user.coordinate = location
                    self.currentUser = user
                }

                print("📍 Updated location: \(location.latitude) \(location.longitude)")
            }
            .store(in: &cancellables)
    }

    // MARK: - LOGGED IN USER (default placeholder)
    private func loadCurrentUser() {
        currentUser = BuilderPin(
            firstName: "Builder",
            lastName: "001",
            project: "Building something",
            status: "Exploring",
            isUrgent: false,
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        )
    }

    // MARK: - MOCK BUILDERS UPDATED TO FIRST/LAST NAMES
    private func loadMockBuilders() {
        builders = [
            BuilderPin(firstName: "Max", lastName: "Yee",
                       project: "BuildPurdue",
                       status: "Need Help",
                       isUrgent: true,
                       coordinate: .init(latitude: 37.7749, longitude: -122.4194)),

            BuilderPin(firstName: "Clarie", lastName: "Yee",
                       project: "OpenCanvas",
                       status: "Building",
                       isUrgent: false,
                       coordinate: .init(latitude: 37.7752, longitude: -122.4183)),

            BuilderPin(firstName: "Pablo", lastName: "Lopez",
                       project: "MoonshotAI",
                       status: "Exploring",
                       isUrgent: false,
                       coordinate: .init(latitude: 34.0522, longitude: -118.2437)),

            BuilderPin(firstName: "Ben", lastName: "Carter",
                       project: "Drone Vision System",
                       status: "Stuck",
                       isUrgent: true,
                       coordinate: .init(latitude: 40.7128, longitude: -74.0060)),

            BuilderPin(firstName: "Nina", lastName: "Ward",
                       project: "Quantum Sim Engine",
                       status: "Building",
                       isUrgent: false,
                       coordinate: .init(latitude: 51.5074, longitude: -0.1278)),

            BuilderPin(firstName: "Yuki", lastName: "Tanaka",
                       project: "HoloBoard",
                       status: "Building",
                       isUrgent: false,
                       coordinate: .init(latitude: 35.6762, longitude: 139.6503)),

            BuilderPin(firstName: "Leo", lastName: "Moreau",
                       project: "Game Dev Toolkit",
                       status: "Need Help",
                       isUrgent: true,
                       coordinate: .init(latitude: 48.8566, longitude: 2.3522)),

            BuilderPin(firstName: "Jade", lastName: "Kim",
                       project: "Fitness AI Coach",
                       status: "Exploring",
                       isUrgent: false,
                       coordinate: .init(latitude: 30.2672, longitude: -97.7431))
        ]
    }

    // MARK: - MOCK EVENTS
    private func loadMockEvents() {
        events = [
            EventPin(title: "SF Builders Hangout", host: "Jhon",
                     description: "Weekly meetup.",
                     isUrgent: false,
                     coordinate: .init(latitude: 37.7749, longitude: -122.4194)),

            EventPin(title: "Robotics Jam", host: "Max",
                     description: "Hardware hacking.",
                     isUrgent: true,
                     coordinate: .init(latitude: 37.7765, longitude: -122.4172)),

            EventPin(title: "Buildspace IRL", host: "Pablo",
                     description: "Show progress.",
                     isUrgent: false,
                     coordinate: .init(latitude: 34.0522, longitude: -118.2437)),

            EventPin(title: "Startup Draft Day", host: "Ben",
                     description: "48-hr build.",
                     isUrgent: true,
                     coordinate: .init(latitude: 32.7157, longitude: -117.1611)),

            EventPin(title: "Night Owls Build Session", host: "Cora",
                     description: "Midnight build.",
                     isUrgent: false,
                     coordinate: .init(latitude: 35.6762, longitude: 139.6503)),

            EventPin(title: "ML Engineering Circle", host: "Arjun",
                     description: "Embeddings talk.",
                     isUrgent: false,
                     coordinate: .init(latitude: 37.3887, longitude: -122.0830)),

            EventPin(title: "Game Dev Collab", host: "Leo",
                     description: "Unity/Godot builds.",
                     isUrgent: false,
                     coordinate: .init(latitude: 48.8566, longitude: 2.3522)),

            EventPin(title: "Hardware Hacking", host: "Sam",
                     description: "Open bench space.",
                     isUrgent: false,
                     coordinate: .init(latitude: 1.3521, longitude: 103.8198))
        ]
    }

    func select(_ builder: BuilderPin) {
        selectedBuilder = builder
    }

    // MARK: - RADIUS CHECK
    func isWithinAllowedRadius(drop: CLLocationCoordinate2D) -> Bool {
        guard let userCoord = currentUser?.coordinate else {
            print("⚠️ No current user coordinate; rejecting drop.")
            return false
        }

        let userLoc = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        let dropLoc = CLLocation(latitude: drop.latitude, longitude: drop.longitude)

        let distance = userLoc.distance(from: dropLoc)

        print("📏 Drop distance: \(distance) m")
        print("🎯 Allowed radius: \(freeRadius) m")

        return distance <= freeRadius // uses the @Published freeRadius
    }

    // MARK: - ADD EVENT PIN FROM TOOLBOX DROP
    func createEventPin(at coordinate: CLLocationCoordinate2D) {
        let newEvent = EventPin(
            title: "New Event",
            host: "Someone",
            description: "User-created event",
            isUrgent: false,
            coordinate: coordinate
        )

        events.append(newEvent)

        print("📌 Created new EventPin at \(coordinate.latitude), \(coordinate.longitude)")
    }
}

