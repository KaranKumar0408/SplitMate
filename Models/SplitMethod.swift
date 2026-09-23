import Foundation

enum SplitMethod: String, Codable, CaseIterable, Identifiable {
    case equal = "Equal"
    case custom = "Custom"
    case percentage = "Percentage"

    var id: String { rawValue }
}
