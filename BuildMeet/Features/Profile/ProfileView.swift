//
//  ProfileView.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var auth: AuthViewModel
    @State private var showDeleteAlert = false

    var body: some View {

        if let user = auth.currentUser {

            ScrollView {
                VStack(spacing: 20) {

                    // PROFILE INITIAL
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(String(user.firstName.prefix(1)))
                                .font(.largeTitle.bold())
                                .foregroundColor(.blue)
                        )

                    // FULL NAME
                    Text(user.fullName)
                        .font(.title.bold())

                    // EMAIL
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Divider().padding(.vertical, 10)

                    // CURRENT PROJECT
                    VStack(spacing: 8) {
                        Text("Current Project")
                            .font(.headline)

                        Text(user.project)
                            .foregroundColor(.secondary)
                    }

                    Divider().padding(.vertical, 10)

                    // STATUS
                    HStack {
                        Image(systemName: "bolt.circle")
                        Text(user.status)
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)

                    Divider().padding(.vertical, 10)

                    // LOGOUT
                    Button("Log Out") {
                        auth.logout()
                    }
                    .foregroundColor(.blue)

                    // DELETE ACCOUNT
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Text("Delete Account")
                    }
                    .alert("Delete Account?", isPresented: $showDeleteAlert) {
                        Button("Delete", role: .destructive) {
                            auth.deleteAccount()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("This action is permanent and cannot be undone.")
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Profile")

        } else {
            Text("No User")
                .font(.title)
                .foregroundColor(.red)
        }
    }
}
