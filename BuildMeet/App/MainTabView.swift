//
//  MainTabView.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            BuilderMapView()
                .tabItem {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Map")
                }

//            EventsView()
//                .tabItem {
//                    Image(systemName: "calendar")
//                    Text("Events")
//                }

            QuestsView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Quests")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
    }
}
