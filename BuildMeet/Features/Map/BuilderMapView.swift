//
//  BuilderMapView.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import SwiftUI
import MapKit

struct BuilderMapView: View {

    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var viewModel = MapViewModel()
    @StateObject var dragVM = DragAndDropPinViewModel()

    @State private var showEventToast = false
    @State private var showRadiusToast = false
    @State private var showToolbox = true

    @State private var dropModeActive = false
    
    @State private var showCreateEventPopup = false
    @State private var pendingEventCoordinate: CLLocationCoordinate2D?


    var body: some View {
        ZStack {

            // 🟩 SUCCESS TOAST
            if showEventToast {
                toastView(
                    icon: "checkmark.circle.fill",
                    text: "Event created!",
                    color: .green
                )
                .zIndex(999)
            }

            // ⛔ RADIUS REJECT TOAST
            if showRadiusToast {
                toastView(
                    icon: "exclamationmark.triangle.fill",
                    text: "Too far — upgrade to Premium to extend your radius.",
                    color: .yellow
                )
                .zIndex(999)
            }

            // 🎯 RADIUS CIRCLE
            if dropModeActive, let user = viewModel.currentUser {
                Circle()
                    .strokeBorder(Color.blue.opacity(0.4), lineWidth: 3)
                    .frame(width: radiusPixelSize(), height: radiusPixelSize())
                    .position(convertCoordinateToPoint(user.coordinate))
                    .zIndex(10)
            }

            // 🌍 MAP
            GlobeMapView(viewModel: viewModel)
                .id(viewModel.events.count)   // refresh pins
                .ignoresSafeArea()
                .zIndex(0)

            // 📌 Floating pin (drag)
            if dragVM.showFloatingPin {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 38))
                    .foregroundColor(.red)
                    .shadow(color: .red.opacity(0.7), radius: 10)
                    .position(dragVM.dragPosition)
                    .zIndex(50)
            }

            // 🔘 Toggle
            VStack {
                HStack {
                    LiquidGlassToggle(viewModel: viewModel)
                    Spacer()
                }
                .padding(.top, 55)
                .padding(.leading, 16)

                Spacer()
            }

            // 🧰 Toolbox
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ToolboxView(
                        isToolboxOpen: $showToolbox,
                        dragVM: dragVM,
                        viewModel: viewModel
                    )
                    .padding(.trailing, 16)
                }
                .padding(.bottom, 50)
            }

            // 🪪 Bottom Sheet (builder)
            if let selected = viewModel.selectedBuilder {
                VStack {
                    Spacer()
                    BuilderBottomSheet(
                        builder: selected,
                        isPresented: $viewModel.selectedBuilder
                    )
                }
            }
            
            // 📄 CREATE EVENT POPUP
            if showCreateEventPopup, let coord = pendingEventCoordinate {
                CreateEventView(
                    initialCoordinate: coord,
                    userCoordinate: viewModel.currentUser!.coordinate,
                    isPresented: $showCreateEventPopup
                )


                .zIndex(9999)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

        }

        // MARK: - ON APPEAR
        .onAppear {

            GlobeMapCoordinateConverter.shared.mapView = GlobeMapView.mapRef

            // Load user identity pin
            if let user = auth.currentUser {
                viewModel.currentUser = BuilderPin(
                    firstName: user.firstName,
                    lastName: user.lastName,
                    project: user.project,
                    status: user.status,
                    isUrgent: false,
                    coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
                )
            }

            // 🟦 ENTER DROP MODE
            NotificationCenter.default.addObserver(
                forName: .enterDropMode,
                object: nil,
                queue: .main
            ) { _ in
                activateDropMode()
            }

            // 🟥 EXIT DROP MODE
            NotificationCenter.default.addObserver(
                forName: .exitDropMode,
                object: nil,
                queue: .main
            ) { _ in
                withAnimation { dropModeActive = false }
            }

            // 🟩 LISTENER: Pin dropped successfully
            NotificationCenter.default.addObserver(
                forName: .eventPinDropped,
                object: nil,
                queue: .main
            ) { notif in

                guard let coord = notif.userInfo?["coordinate"] as? CLLocationCoordinate2D else {
                    print("❌ No coordinate found")
                    return
                }

                print("📌 Pin dropped at", coord)

                // ⭐ Open event creation popup instead of creating event
                pendingEventCoordinate = coord
                withAnimation { showCreateEventPopup = true }
            }

            // ⛔ REJECT LISTENER
            NotificationCenter.default.addObserver(
                forName: .eventPinDropRejected,
                object: nil,
                queue: .main
            ) { _ in
                print("🚫 Drop rejected (toast)")
                withAnimation { showRadiusToast = true }
            }
        }

    }

    // MARK: - Activate Drop Mode
    private func activateDropMode() {
        guard let userCoord = viewModel.currentUser?.coordinate else { return }

        dropModeActive = true

        let free = viewModel.freeRadius   // meters radius

        let region = MKCoordinateRegion(
            center: userCoord,
            latitudinalMeters: free * 2,
            longitudinalMeters: free * 2
        )

        GlobeMapView.mapRef?.setRegion(region, animated: true)
    }

    // MARK: - Toast View
    private func toastView(icon: String, text: String, color: Color) -> some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(text).bold()
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(radius: 10)
            .padding(.top, 60)

            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    if color == .green { showEventToast = false }
                    if color == .yellow { showRadiusToast = false }
                }
            }
        }
    }

    private func convertCoordinateToPoint(_ coord: CLLocationCoordinate2D) -> CGPoint {
        guard let map = GlobeMapView.mapRef else { return .zero }
        return map.convert(coord, toPointTo: nil)
    }

    private func radiusPixelSize() -> CGFloat {
        guard let map = GlobeMapView.mapRef,
              let user = viewModel.currentUser else { return 0 }

        let free = viewModel.freeRadius

        let coord1 = user.coordinate
        let coord2 = CLLocationCoordinate2D(
            latitude: coord1.latitude,
            longitude: coord1.longitude + 0.01
        )

        let p1 = map.convert(coord1, toPointTo: nil)
        let p2 = map.convert(coord2, toPointTo: nil)

        let metersPerPoint = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
            .distance(from: CLLocation(latitude: coord2.latitude, longitude: coord2.longitude))

        let pixelsPerMeter = abs(p2.x - p1.x) / metersPerPoint

        return CGFloat(free) * pixelsPerMeter * 2
    }
}

