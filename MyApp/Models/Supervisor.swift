import Foundation

struct Supervisor: Equatable, Sendable {
    let firstname: String
    let lastname: String
    let phoneNumber: String

    init?(user: User) {
        guard user.rol == Roles.supervisor.stringValue else { return nil }
        firstname = user.firstname
        lastname = user.lastname
        phoneNumber = user.phoneNumber
    }
}
