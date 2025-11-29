//
//  UserStorage.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import Foundation

class UserStorage {
    private let storageKey = "buildmeet_local_user"

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
}
