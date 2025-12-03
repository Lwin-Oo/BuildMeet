//
//  CreateEventView.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import SwiftUI
import MapKit

// -------------------------------------
// Reusable Field Component
// -------------------------------------
struct BMField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.primary)

            TextField(placeholder, text: $text)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}


// -------------------------------------
// Main CreateEventView
// -------------------------------------
struct CreateEventView: View {

    let initialCoordinate: CLLocationCoordinate2D
    let userCoordinate: CLLocationCoordinate2D

    @Binding var isPresented: Bool

    // Radius limit
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
    @State private var isLoadingAddress = true

    // Search
    @State private var searchQuery: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var searchError: String?

    // Debouncer
    @State private var searchDebounceTask: DispatchWorkItem?

    // Init
    init(initialCoordinate: CLLocationCoordinate2D,
         userCoordinate: CLLocationCoordinate2D,
         isPresented: Binding<Bool>) {

        self.initialCoordinate = initialCoordinate
        self.userCoordinate = userCoordinate
        self._isPresented = isPresented
        self._editableCoordinate = State(initialValue: initialCoordinate)
    }


    // -------------------------------------
    // BODY
    // -------------------------------------
    var body: some View {
        ZStack {

            // Dim background
            Color.black.opacity(0.40)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.35)) {
                        isPresented = false
                    }
                }

            VStack {
                Spacer()

                VStack(spacing: 22) {

                    // Grab Bar
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)

                    // Header
                    HStack {
                        Text("Create Event")
                            .font(.system(size: 22, weight: .semibold))

                        Spacer()

                        Button {
                            withAnimation(.spring(response: 0.35)) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)


                    // CONTENT SCROLL
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 22) {

                            // -------------------------------------
                            // Mini Map + Address
                            // -------------------------------------
                            VStack(alignment: .leading, spacing: 10) {

                                Text("Location")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Map(coordinateRegion: .constant(
                                    MKCoordinateRegion(
                                        center: editableCoordinate,
                                        span: .init(latitudeDelta: 0.004,
                                                    longitudeDelta: 0.004)
                                    )
                                ))
                                .frame(height: 120)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )

                                if isLoadingAddress {
                                    ProgressView()
                                } else {
                                    Text(address)
                                        .font(.footnote)
                                        .foregroundColor(.primary)
                                }

                            }
                            .padding(.horizontal)


                            // -------------------------------------
                            // SEARCH
                            // -------------------------------------
                            VStack(alignment: .leading, spacing: 10) {

                                Text("Adjust Location")
                                    .font(.subheadline.weight(.semibold))

                                // Real-time search bar
                                TextField("Search a place…", text: $searchQuery)
                                    .padding(12)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .onChange(of: searchQuery) { _ in
                                        debounceSearch()
                                    }

                                // Searching indicator
                                if isSearching {
                                    ProgressView()
                                        .padding(.top, 4)
                                }

                                if let error = searchError {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }

                                // Search results dropdown
                                if !searchResults.isEmpty {
                                    VStack(spacing: 8) {
                                        ForEach(searchResults, id: \.self) { item in
                                            Button {
                                                handleSearchSelection(item)
                                            } label: {
                                                VStack(alignment: .leading, spacing: 3) {
                                                    Text(item.name ?? "Unknown")
                                                        .font(.headline)

                                                    Text(item.placemark.title ?? "")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }
                                                .padding(12)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color(.secondarySystemBackground))
                                                .cornerRadius(10)
                                            }
                                        }
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }

                            }
                            .padding(.horizontal)


                            Divider().padding(.horizontal)


                            // Title + description
                            BMField(title: "Event Title",
                                    placeholder: "e.g. Night Build Session",
                                    text: $title)

                            BMField(title: "Description",
                                    placeholder: "What’s happening?",
                                    text: $description)


                            // Date picker
                            VStack(alignment: .leading, spacing: 6) {
                                Text("When")
                                    .font(.subheadline.bold())

                                DatePicker("Select Time",
                                           selection: $eventDate)
                                    .datePickerStyle(.compact)
                            }
                            .padding(.horizontal)


                            // Urgency
                            Toggle(isOn: $isUrgent) {
                                Label("Urgent Event", systemImage: "flame.fill")
                            }
                            .padding(.horizontal)

                        }
                        .padding(.bottom, 12)
                    }


                    // -------------------------------------
                    // Bottom Create Button
                    // -------------------------------------
                    Button {
                        print("📌 EVENT SAVED:")
                        print("Title:", title)
                        print("Desc:", description)
                        print("Coord:", editableCoordinate)

                        withAnimation(.spring(response: 0.35)) {
                            isPresented = false
                        }

                    } label: {
                        Text("Create Event")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(title.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .padding(.horizontal)
                    }
                    .disabled(title.isEmpty)

                    Spacer(minLength: 10)
                }
                .frame(maxWidth: 420)
                .background(.ultraThinMaterial)
                .cornerRadius(28)
                .shadow(radius: 35)
                .padding(.bottom, 15)
            }
        }
        .onAppear {
            reverseGeocode(for: editableCoordinate)
        }
    }


    // -----------------------------------------------------
    // SEARCH — REAL TIME WITH DEBOUNCE
    // -----------------------------------------------------
    private func debounceSearch() {
        searchDebounceTask?.cancel()

        let task = DispatchWorkItem {
            if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.searchResults = []
                return
            }
            performSearch()
        }

        searchDebounceTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: task)
    }


    private func performSearch() {
        searchError = nil

        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = searchQuery
        req.region = MKCoordinateRegion(
            center: userCoordinate,
            latitudinalMeters: allowedRadiusMeters * 2,
            longitudinalMeters: allowedRadiusMeters * 2
        )

        isSearching = true

        MKLocalSearch(request: req).start { resp, _ in
            isSearching = false
            searchResults = resp?.mapItems ?? []
        }
    }


    // -----------------------------------------------------
    // ON SELECTION — CLOSE DROPDOWN + FILL SEARCH BOX
    // -----------------------------------------------------
    private func handleSearchSelection(_ item: MKMapItem) {
        guard let newCoord = item.placemark.location?.coordinate else { return }

        let dist = distance(from: userCoordinate, to: newCoord)
        if dist > allowedRadiusMeters {
            searchError = "❌ This location is outside your radius."
            return
        }

        editableCoordinate = newCoord
        reverseGeocode(for: newCoord)

        withAnimation(.easeOut(duration: 0.25)) {
            searchQuery = item.name ?? ""
            searchResults = []       // Hide dropdown
        }

        searchError = nil
    }


    // -----------------------------------------------------
    // Reverse Geocode
    // -----------------------------------------------------
    private func reverseGeocode(for coord: CLLocationCoordinate2D) {
        isLoadingAddress = true

        CLGeocoder().reverseGeocodeLocation(
            CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        ) { marks, _ in

            if let p = marks?.first {
                address = [p.name,
                           p.locality,
                           p.administrativeArea,
                           p.country]
                    .compactMap { $0 }
                    .joined(separator: ", ")
            } else {
                address = "Unknown location"
            }

            isLoadingAddress = false
        }
    }

    // -----------------------------------------------------
    // Distance Function
    // -----------------------------------------------------
    private func distance(from a: CLLocationCoordinate2D,
                          to b: CLLocationCoordinate2D) -> Double {
        CLLocation(latitude: a.latitude, longitude: a.longitude)
            .distance(from: CLLocation(latitude: b.latitude, longitude: b.longitude))
    }
}


#Preview {
    CreateEventView(
        initialCoordinate: .init(latitude: 37.7749, longitude: -122.4194),
        userCoordinate: .init(latitude: 37.7749, longitude: -122.4194),
        isPresented: .constant(true)
    )
}

