//
//  CreateEventView.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import SwiftUI
import MapKit

struct CreateEventView: View {

    // Dropped pin (initial)
    let initialCoordinate: CLLocationCoordinate2D

    // User real location
    let userCoordinate: CLLocationCoordinate2D

    @Binding var isPresented: Bool

    // Radius limit (meters)
    @State private var allowedRadiusMeters: Double = 3000 

    // Editable location inside form
    @State private var editableCoordinate: CLLocationCoordinate2D

    // Form fields
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var eventDate: Date = Date()
    @State private var isUrgent: Bool = false

    // Reverse geocode
    @State private var address: String = "Loading address…"
    @State private var isLoadingAddress: Bool = true

    // Search
    @State private var searchQuery: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching: Bool = false
    @State private var searchError: String?

    // MARK: - INIT
    init(
        initialCoordinate: CLLocationCoordinate2D,
        userCoordinate: CLLocationCoordinate2D,
        isPresented: Binding<Bool>
    ) {
        self.initialCoordinate = initialCoordinate
        self.userCoordinate = userCoordinate
        self._isPresented = isPresented
        self._editableCoordinate = State(initialValue: initialCoordinate)
    }

    var body: some View {
        ZStack {

            // Background dim
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { withAnimation { isPresented = false } }

            VStack(spacing: 20) {

                // HEADER
                HStack {
                    Text("Create Event")
                        .font(.title2.bold())
                    Spacer()
                    Button {
                        withAnimation { isPresented = false }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.secondary)
                    }
                }

                // LOCATION (reverse-geocoded)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Location")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if isLoadingAddress {
                        ProgressView()
                    } else {
                        Text(address)
                            .font(.footnote)
                    }
                }

                // LOCATION SEARCH
                VStack(alignment: .leading, spacing: 6) {
                    Text("Adjust Location")
                        .font(.subheadline.bold())

                    HStack {
                        TextField("Search a place…", text: $searchQuery)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button("Search") {
                            performSearch()
                        }
                        .disabled(searchQuery.isEmpty)
                    }

                    if isSearching {
                        ProgressView().padding(.top, 4)
                    }

                    if let error = searchError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 2)
                    }

                    // SEARCH RESULTS
                    if !searchResults.isEmpty {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(searchResults, id: \.self) { item in
                                    Button {
                                        handleSearchSelection(item)
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text(item.name ?? "Unknown")
                                                .font(.headline)

                                            Text(item.placemark.title ?? "")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 150)
                    }
                }

                Divider().padding(.vertical, 4)

                // TITLE
                VStack(alignment: .leading, spacing: 6) {
                    Text("Event Title")
                        .font(.subheadline.bold())
                    TextField("e.g. Night Build Session", text: $title)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }

                // DESCRIPTION
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                        .font(.subheadline.bold())
                    TextField("What’s happening?", text: $description)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }

                // DATE PICKER
                VStack(alignment: .leading, spacing: 6) {
                    Text("When")
                        .font(.subheadline.bold())
                    DatePicker("Select Time", selection: $eventDate)
                        .datePickerStyle(.compact)
                }

                // URGENCY
                Toggle(isOn: $isUrgent) {
                    Label("Urgent Event", systemImage: "flame.fill")
                }

                Spacer(minLength: 0)

                // SUBMIT
                Button {
                    print("📌 EVENT READY TO SAVE:")
                    print("Title:", title)
                    print("Desc:", description)
                    print("Urgent:", isUrgent)
                    print("Time:", eventDate)
                    print("Address:", address)
                    print("Coord:", editableCoordinate)

                    withAnimation { isPresented = false }
                } label: {
                    Text("Create Event")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(title.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(title.isEmpty)
            }
            .padding(20)
            .frame(maxWidth: 380)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .shadow(radius: 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear { reverseGeocode(for: editableCoordinate) }
        }
    }

    // MARK: - SEARCH
    private func performSearch() {
        searchError = nil
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = searchQuery
        req.region = MKCoordinateRegion(
            center: userCoordinate, // search around the user
            latitudinalMeters: allowedRadiusMeters * 2,
            longitudinalMeters: allowedRadiusMeters * 2
        )

        isSearching = true
        MKLocalSearch(request: req).start { resp, err in
            isSearching = false
            searchResults = resp?.mapItems ?? []
        }
    }

    // MARK: - HANDLE SELECTION
    private func handleSearchSelection(_ item: MKMapItem) {
        guard let newCoord = item.placemark.location?.coordinate else { return }

        let dist = distance(from: userCoordinate, to: newCoord)

        if dist > allowedRadiusMeters {
            searchError = "❌ This location is outside your radius."
            return
        }

        editableCoordinate = newCoord
        reverseGeocode(for: newCoord)
        searchError = nil
    }

    // MARK: - REVERSE GEOCODE
    private func reverseGeocode(for coord: CLLocationCoordinate2D) {
        isLoadingAddress = true
        let loc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)

        CLGeocoder().reverseGeocodeLocation(loc) { marks, _ in
            if let p = marks?.first {
                let parts = [
                    p.name,
                    p.locality,
                    p.administrativeArea,
                    p.country
                ].compactMap { $0 }

                address = parts.joined(separator: ", ")
            } else {
                address = "Unknown location"
            }
            isLoadingAddress = false
        }
    }

    // MARK: - DISTANCE
    private func distance(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> Double {
        let la = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let lb = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return la.distance(from: lb)
    }
}

#Preview {
    CreateEventView(
        initialCoordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        userCoordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        isPresented: .constant(true)
    )
}
