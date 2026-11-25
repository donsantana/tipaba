import Foundation
import Observation

@MainActor
@Observable
final class PatientViewModel {
    private(set) var patients: [Patient]
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init() {
        patients = []
    }

    func fetchPatients() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            patients = try await CloudKitService.shared.fetchPatients()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
