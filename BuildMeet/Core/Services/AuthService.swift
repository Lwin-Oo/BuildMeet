//
//  AuthService.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import Foundation

class AuthService {

    static let shared = AuthService()
    private init() {}

    private let storageKey = "buildmeet_local_user"

    // MARK: - Save User
    func saveUser(_ user: LocalUser) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    func loadUser() -> LocalUser? {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let user = try? JSONDecoder().decode(LocalUser.self, from: data)
        else { return nil }
        return user
    }

    func clearUser() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - SIGN UP (UPDATED)
    func signUp(firstName: String, lastName: String, email: String, password: String) -> LocalUser {

        let newUser = LocalUser(
            id: UUID().uuidString,
            firstName: firstName,
            lastName: lastName,
            email: email.lowercased(),
            password: password,
            project: "Not Started",
            status: "Exploring"
        )

        saveUser(newUser)
        return newUser
    }

    // MARK: - LOGIN
    func login(email: String, password: String) -> LocalUser? {
        guard let saved = loadUser() else { return nil }

        if saved.email == email.lowercased() && saved.password == password {
            return saved
        }

        return nil
    }
}
