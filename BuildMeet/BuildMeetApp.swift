//
//  BuildMeetApp.swift
//  BuildMeet
//

import SwiftUI

@main
struct BuildMeetApp: App {
    @StateObject var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
        }
    }
}

