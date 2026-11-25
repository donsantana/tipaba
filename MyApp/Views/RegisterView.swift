//
//  RegisterView.swift
//  Tipaba
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss

    private let userViewModel: UserViewModel
    private let onSignIn: () -> Void

    @State private var firstname = ""
    @State private var lastname = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmedPassword = ""
    @State private var rol: Roles = .clinician
    @State private var showsPassword = false
    @State private var showsConfirmedPassword = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showsRegistrationAlert = false

    private let navy = Color(red: 0.03, green: 0.15, blue: 0.32)
    private let secondaryText = Color(red: 0.32, green: 0.39, blue: 0.52)
    private let blue = Color(red: 0.02, green: 0.45, blue: 0.95)

    @MainActor
    init(userViewModel: UserViewModel? = nil, onSignIn: @escaping () -> Void = {}) {
        self.userViewModel = userViewModel ?? UserViewModel()
        self.onSignIn = onSignIn
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                decorativeBackground(in: geometry.size)

                ScrollView {
                    VStack(spacing: 0) {
                        Image("SignInImg")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .accessibilityLabel("TipAba")
                            .padding(.top, 50)

                        Text(GlobalStrings.createAccount)
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(navy)
                            .padding(.top, 5)

                        Text("Join TipAba and access ABA strategies,\nbehaviors and practical tips.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(secondaryText)
                            .padding(.top, 5)

                        VStack(spacing: 12) {
                            nameField(
                                title: "First Name",
                                text: $firstname,
                                contentType: .givenName
                            )

                            nameField(
                                title: "Last Name",
                                text: $lastname,
                                contentType: .familyName
                            )

                            phoneField
                            passwordField
                            confirmedPasswordField
                        }
                        .padding(.top, 10)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("I am a...")
                                .font(.title3.bold())
                                .foregroundStyle(navy)

                            HStack(spacing: 10) {
                                roleButton(role: .clinician, icon: "stethoscope")
                                roleButton(role: .supervisor, icon: "person.3.fill")
                                roleButton(role: .parent, icon: "house")
                            }
                        }
                        .padding(.top, 10)

                        Button {
                            Task {
                                await register()
                            }
                        } label: {
                            Group {
                                if userViewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Create Account")
                                        .font(.headline)
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(blue.gradient, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .disabled(userViewModel.isLoading)
                        .padding(.top, 24)

                        HStack(spacing: 6) {
                            Text("Already have an account?")
                                .foregroundStyle(secondaryText)

                            Button("Sign In") {
                                onSignIn()
                                dismiss()
                            }
                            .disabled(userViewModel.isLoading)
                            .fontWeight(.semibold)
                            .foregroundStyle(blue)
                        }
                        .font(.subheadline)
                        .padding(.top, 18)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 145)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
            }
            .background(Color.white)
            .ignoresSafeArea(edges: .vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertTitle, isPresented: $showsRegistrationAlert) {
            Button(GlobalStrings.ok, role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private func nameField(
        title: LocalizedStringKey,
        text: Binding<String>,
        contentType: UITextContentType
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "person")
                .foregroundStyle(secondaryText)
                .frame(width: 22)

            TextField(title, text: text)
                .textContentType(contentType)
                .textInputAutocapitalization(.words)
                .foregroundStyle(navy)
        }
        .registrationFieldStyle()
    }

    private var phoneField: some View {
        HStack(spacing: 14) {
            Image(systemName: "phone")
                .foregroundStyle(secondaryText)
                .frame(width: 22)

            TextField("Phone Number", text: $phoneNumber)
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
                .foregroundStyle(navy)
        }
        .registrationFieldStyle()
    }

    private var passwordField: some View {
        passwordInput(
            title: "Password",
            text: $password,
            isVisible: $showsPassword
        )
    }

    private var confirmedPasswordField: some View {
        passwordInput(
            title: "Confirm Password",
            text: $confirmedPassword,
            isVisible: $showsConfirmedPassword
        )
    }

    private func passwordInput(
        title: LocalizedStringKey,
        text: Binding<String>,
        isVisible: Binding<Bool>
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "lock")
                .foregroundStyle(secondaryText)
                .frame(width: 22)

            Group {
                if isVisible.wrappedValue {
                    TextField(title, text: text)
                } else {
                    SecureField(title, text: text)
                }
            }
            .textContentType(.newPassword)
            .foregroundStyle(navy)

            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                    .foregroundStyle(secondaryText)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isVisible.wrappedValue ? "Hide password" : "Show password")
        }
        .registrationFieldStyle()
    }

    private func roleButton(role: Roles, icon: String) -> some View {
        let isSelected = rol == role

        return Button {
            rol = role
        } label: {
            VStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(height: 26)

                Text(role.stringValue)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(isSelected ? blue : navy)
            .frame(maxWidth: .infinity)
            .frame(height: 88)
            .background(isSelected ? blue.opacity(0.08) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? blue : Color.gray.opacity(0.25), lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
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
    private func register() async {
        guard !firstname.isEmpty,
              !lastname.isEmpty,
              !phoneNumber.isEmpty,
              !password.isEmpty else {
            showAlert(
                title: "Missing Information",
                message: "Complete every field before creating your account."
            )
            return
        }

        guard password == confirmedPassword else {
            showAlert(
                title: "Passwords Do Not Match",
                message: "Enter the same password in both password fields."
            )
            return
        }

        let user = User(
            firstname: firstname,
            lastname: lastname,
            password: password,
            phoneNumber: phoneNumber,
            rol: rol.stringValue
        )

        if await userViewModel.register(user: user) {
            showAlert(
                title: "Registration Complete",
                message: "Your account was created successfully."
            )
            clearForm()
        } else if let errorMessage = userViewModel.errorMessage {
            showAlert(title: "Registration Failed", message: errorMessage)
        }
    }

    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showsRegistrationAlert = true
    }

    private func clearForm() {
        firstname = ""
        lastname = ""
        phoneNumber = ""
        password = ""
        confirmedPassword = ""
        rol = .clinician
    }
}

private extension View {
    func registrationFieldStyle() -> some View {
        padding(.horizontal, 16)
            .frame(height: 52)
            .background(.white, in: RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.28), lineWidth: 1.5)
            }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
