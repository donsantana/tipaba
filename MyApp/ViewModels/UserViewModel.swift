//
//  UserViewModel.swift
//  Tipaba
//
//  Created by Done Santana on 11/23/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class UserViewModel {
    private(set) var currentUser: User?
    private(set) var users: [User] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let cloudKitService: CloudKitService
    private var sessionVersion = 0
    
    var nameInitials: String {
        "\(currentUser?.firstname.first.map(String.init) ?? "")\(currentUser?.lastname.first.map(String.init) ?? "")"
    }

    init(cloudKitService: CloudKitService = .shared) {
        self.cloudKitService = cloudKitService
    }

    @discardableResult
    func register(user: User) async -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await cloudKitService.register(user: user)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func signIn(phoneNumber: String, password: String) async -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        errorMessage = nil
        let version = sessionVersion
        defer { isLoading = false }

        do {
            let user = try await cloudKitService.signIn(phoneNumber: phoneNumber, password: password)
            guard version == sessionVersion else { return false }
            currentUser = user
            return true
        } catch {
            if version == sessionVersion {
                errorMessage = error.localizedDescription
            }
            return false
        }
    }

    func fetchUsers() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        let version = sessionVersion
        defer { isLoading = false }

        do {
            let fetchedUsers = try await cloudKitService.fetchUsers()
            guard version == sessionVersion else { return }
            users = fetchedUsers
        } catch {
            if version == sessionVersion {
                errorMessage = error.localizedDescription
            }
        }
    }

    func signOut() {
        sessionVersion += 1
        currentUser = nil
        users = []
        errorMessage = nil
    }

    func clearError() {
        errorMessage = nil
    }
}
