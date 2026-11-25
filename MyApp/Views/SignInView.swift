//
//  SignInView.swift
//  Tipaba
//
//  Created by Done Santana on 10/25/26.
//

import SwiftUI

struct SignInView: View {
    @State private var phoneNumber = "7864476528"
    @State private var password = "ok"
    @State private var showsPassword = false
    @State private var showsRegisterView = false
    @State private var userViewModel = UserViewModel()
    @State private var alertMessage = ""
    @State private var showsSignInAlert = false

    private let navy = Color(red: 0.03, green: 0.15, blue: 0.32)
    private let secondaryText = Color(red: 0.32, green: 0.39, blue: 0.52)
    private let blue = Color(red: 0.02, green: 0.45, blue: 0.95)

    var body: some View {
        if let user = userViewModel.currentUser {
            switch Roles.allCases.first(where: { $0.stringValue.caseInsensitiveCompare(user.rol.trimmingCharacters(in: .whitespacesAndNewlines)) == .orderedSame }) {
            case .parent:
                ParentDashboard(userViewModel: userViewModel)
            case .clinician:
                ClinicianDashboard(userViewModel: userViewModel)
            case .supervisor:
                SupervisorDashoard()
            case nil:
                VStack(spacing: 16) {
                    Text("This account has an unrecognized role.")
                    Button("Sign Out") { userViewModel.signOut() }
                }
            }
        } else {
            signInContent
        }
    }

    private var signInContent: some View {
        GeometryReader { geometry in
            ZStack {
                decorativeBackground(in: geometry.size)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Image("SignInImg")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .accessibilityLabel("TipAba")

                        Text("Sign In")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(navy)
                            .padding(.top, 14)

                        Text("Access ABA strategies, behaviors\nand practical tips.")
                            .font(.body)
                            .foregroundStyle(secondaryText)
                            .padding(.top, 4)

                        phoneNumberField
                            .padding(.top, 28)

                        passwordField
                            .padding(.top, 14)

                        Button {
                            Task { await signIn() }
                        } label: {
                            Group {
                                if userViewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Sign In")
                                }
                            }
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(blue.gradient, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .disabled(userViewModel.isLoading)
                        .padding(.top, 24)

                        Button("Forgot Password?") {
                            forgotPassword()
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(blue)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 18)
                        
                        Button("Create an account") {
                            createAccount()
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(blue)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 18)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 100)
                    .frame(maxWidth: 520)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
            .background(Color.white)
            .ignoresSafeArea(edges: [.bottom, .top])
            .alert("Sign In", isPresented: $showsSignInAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .overlay {
                if showsRegisterView {
                    RegisterView(userViewModel: userViewModel) {
                        showsRegisterView = false
                    }
                }
            }
        }
    }

    private var phoneNumberField: some View {
        HStack(spacing: 14) {
            Image(systemName: "phone")
                .foregroundStyle(secondaryText)
                .frame(width: 22)

            TextField("Phone number", text: $phoneNumber)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
                .foregroundStyle(navy)
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.28), lineWidth: 1.5)
        }
    }

    private var passwordField: some View {
        HStack(spacing: 14) {
            Image(systemName: "lock")
                .foregroundStyle(secondaryText)
                .frame(width: 22)

            Group {
                if showsPassword {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
            }
            .textContentType(.password)
            .foregroundStyle(navy)

            Button {
                showsPassword.toggle()
            } label: {
                Image(systemName: showsPassword ? "eye.slash" : "eye")
                    .foregroundStyle(secondaryText)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(showsPassword ? "Hide password" : "Show password")
        }
        .padding(.horizontal, 16)
        .frame(height: 54)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.28), lineWidth: 1.5)
        }
    }

    private func decorativeBackground(in size: CGSize) -> some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.88, green: 0.95, blue: 1.0))
                .frame(width: 250, height: 250)
                .position(x: size.width + 30, y: -30)

            Ellipse()
                .fill(Color(red: 1.0, green: 0.78, blue: 0.25))
                .frame(width: size.width * 0.8, height: 150)
                .position(x: size.width * 0.52, y: size.height + 45)

            Ellipse()
                .fill(Color(red: 1.0, green: 0.30, blue: 0.34))
                .frame(width: size.width * 0.9, height: 190)
                .rotationEffect(.degrees(-10))
                .position(x: size.width, y: size.height + 28)

            Ellipse()
                .fill(Color(red: 0.20, green: 0.68, blue: 0.96))
                .frame(width: size.width, height: 205)
                .rotationEffect(.degrees(12))
                .position(x: 0, y: size.height + 25)
        }
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    @MainActor
    private func signIn() async {
        let phone = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phone.isEmpty, !password.isEmpty else {
            alertMessage = "Enter your phone number and password."
            showsSignInAlert = true
            return
        }

        if await userViewModel.signIn(phoneNumber: phone, password: password) {
            password = ""
        } else if let errorMessage = userViewModel.errorMessage {
            alertMessage = errorMessage
            showsSignInAlert = true
        }
    }
    
    private func createAccount() {
        showsRegisterView = true
    }

    private func forgotPassword() {
        // Connect the password recovery flow here.
    }
}

#Preview {
    SignInView()
}
