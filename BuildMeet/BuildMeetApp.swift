//
//  BuildMeetApp.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/24/25.
//

import SwiftUI
import CoreData

@main
struct BuildMeetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
