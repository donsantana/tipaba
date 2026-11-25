import Foundation
import Observation

@MainActor
@Observable
final class SupervisorViewModel {
    private(set) var supervisors: [Supervisor] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let cloudKitService: CloudKitService

    init(cloudKitService: CloudKitService? = nil) {
        self.cloudKitService = cloudKitService ?? .shared
    }

    func fetchSupervisors() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            supervisors = try await cloudKitService.fetchUsers().compactMap(Supervisor.init(user:))
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
