//
//  LoginView.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var error = ""

    var body: some View {
        VStack(spacing: 24) {

            Text("Log In")
                .font(.largeTitle.bold())

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if !error.isEmpty {
                Text(error)
                    .foregroundColor(.red)
            }

            Button("Log In") {
                if !auth.login(email: email, password: password) {
                    error = "Invalid credentials"
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)

            NavigationLink("Create Account") {
                SignupView()
            }
            .font(.footnote)
        }
        .padding()
    }
}
