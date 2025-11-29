//
//  AuthViewModel.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//


import Foundation
import Combine 

class AuthViewModel: ObservableObject {

    @Published var currentUser: LocalUser?
    @Published var isAuthenticated: Bool = false

    private let userKey = "LOCAL_AUTH_USER"

    init() {
        loadUser()
    }

    // MARK: - Signup
    func signUp(firstName: String, lastName: String, email: String, password: String) {
        let user = LocalUser(
            id: UUID().uuidString,
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            project: "Getting Started",
            status: "Exploring"
        )

        saveUser(user)
        currentUser = user
        isAuthenticated = true
    }


    // MARK: - Login
    func login(email: String, password: String) -> Bool {
        guard let saved = loadUser() else { return false }
        if saved.email == email && saved.password == password {
            currentUser = saved
            isAuthenticated = true
            return true
        }
        return false
    }
    
    // MARK: - Delete
    func deleteAccount() {
        // Remove user data from storage
        UserDefaults.standard.removeObject(forKey: userKey)

        // Clear memory
        currentUser = nil
        isAuthenticated = false
    }


    // MARK: - Logout
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }

    // MARK: - Local Storage
    private func saveUser(_ user: LocalUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    @discardableResult
    private func loadUser() -> LocalUser? {
        guard let data = UserDefaults.standard.data(forKey: userKey),
              let user = try? JSONDecoder().decode(LocalUser.self, from: data) else {
            return nil
        }

        currentUser = user
        isAuthenticated = true
        return user
    }
}
