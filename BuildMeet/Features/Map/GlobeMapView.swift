//
//  GlobeMapView.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import SwiftUI
import MapKit

struct GlobeMapView: UIViewRepresentable {

    @ObservedObject var viewModel: MapViewModel
    static var mapRef: MKMapView?


    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()

        map.delegate = context.coordinator
        map.showsUserLocation = true
        
        GlobeMapView.mapRef = map
        GlobeMapCoordinateConverter.shared.mapView = map


        // 🌍 Enable full 3D globe mode
        map.preferredConfiguration =
            MKImageryMapConfiguration(elevationStyle: .realistic)

        // Add initial pins
        addPins(to: map)

        return map
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {

        // ❌ DO NOT SET REGION HERE — allows full freedom.
        // uiView.setRegion(viewModel.region, animated: true)

        // Refresh pins only
        uiView.removeAnnotations(uiView.annotations)
        addPins(to: uiView)
    }

    // MARK: - Add Pins
    private func addPins(to map: MKMapView) {

        // Logged-in user pin (blue glowing)
        if let user = viewModel.currentUser {
            let ann = MKPointAnnotation()
            ann.title = user.fullName
            ann.subtitle = user.project
            ann.coordinate = user.coordinate
            map.addAnnotation(ann)
        }

        if viewModel.showPeople {
            let annotations = viewModel.builders.map { builder -> MKPointAnnotation in
                let ann = MKPointAnnotation()
                ann.title = builder.fullName
                ann.subtitle = builder.project
                ann.coordinate = builder.coordinate
                return ann
            }
            map.addAnnotations(annotations)

        } else {
            let annotations = viewModel.events.map { event -> MKPointAnnotation in
                let ann = MKPointAnnotation()
                ann.title = event.title
                ann.subtitle = event.description
                ann.coordinate = event.coordinate
                return ann
            }
            map.addAnnotations(annotations)
        }
    }

    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: GlobeMapView

        init(_ parent: GlobeMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView,
                     viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {

            guard !(annotation is MKUserLocation) else { return nil }

            let view = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: "pin"
            )

            if parent.viewModel.showPeople {
                view.markerTintColor = .systemBlue
                view.glyphText = "🛠️"  // builders
            } else {
                view.markerTintColor = .systemRed
                view.glyphText = "🎉"  // events
            }

            return view
        }
    }
}

