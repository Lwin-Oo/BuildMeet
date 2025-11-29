//
//  SignUpView.swift
//  BuildMeet
//
//  Created by Lwin Oo on 11/26/25.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var auth: AuthViewModel

    // MARK: - Form State
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    // Show / Hide password toggles
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    @State private var errorMessage = ""

    // MARK: - Validation
    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }

    var body: some View {
        VStack(spacing: 24) {

            Text("Create Account")
                .font(.largeTitle.bold())

            // FIRST NAME
            TextField("First Name", text: $firstName)
                .textFieldStyle(.roundedBorder)

            // LAST NAME
            TextField("Last Name", text: $lastName)
                .textFieldStyle(.roundedBorder)

            // EMAIL
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            // PASSWORD FIELD
            ZStack(alignment: .trailing) {
                Group {
                    if showPassword {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .textFieldStyle(.roundedBorder)

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }

            // CONFIRM PASSWORD FIELD
            ZStack(alignment: .trailing) {
                Group {
                    if showConfirmPassword {
                        TextField("Confirm Password", text: $confirmPassword)
                    } else {
                        SecureField("Confirm Password", text: $confirmPassword)
                    }
                }
                .textFieldStyle(.roundedBorder)

                Button {
                    showConfirmPassword.toggle()
                } label: {
                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 10)
            }

            // ERROR MESSAGE
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            // SIGN UP BUTTON
            Button(action: handleSignup) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isFormValid)
            .opacity(isFormValid ? 1 : 0.5)
            .padding(.top, 10)

        }
        .padding()
    }

    // MARK: - Actions
    func handleSignup() {
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }

        auth.signUp(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password
        )
    }

}
