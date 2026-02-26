import SwiftUI

// MARK: - Occasion Enum
enum Occasion: String, CaseIterable, Identifiable, Codable {
    case casual  = "Casual"
    case formal  = "Formal"
    case party   = "Party"
    case work    = "Work"
    case outdoor = "Outdoor"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .casual:  return "sun.max.fill"
        case .formal:  return "briefcase.fill"
        case .party:   return "star.fill"
        case .work:    return "laptopcomputer"
        case .outdoor: return "leaf.fill"
        }
    }

    var color: Color {
        switch self {
        case .casual:  return Color(hex: "FFD89B")
        case .formal:  return Color(hex: "C4C4E8")
        case .party:   return Color(hex: "FFB3C6")
        case .work:    return Color(hex: "B3D9C4")
        case .outdoor: return Color(hex: "A8D5A2")
        }
    }
}
