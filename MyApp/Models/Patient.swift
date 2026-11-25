import Foundation

struct Patient: Identifiable, Equatable, Sendable {
    let id: String
    var firstname: String
    var lastname: String
}
