import SwiftUI

// MARK: - Clothing Category Enum
enum ClothingCategory: String, CaseIterable, Identifiable, Codable {
    case tops        = "Tops"
    case pants       = "Pants"
    case jeans       = "Jeans"
    case dresses     = "Dresses"
    case shoes       = "Shoes"
    case accessories = "Accessories"
    case miscellaneous = "Misc"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .tops:         return "tshirt.fill"
        case .pants:        return "rectangle.split.1x2.fill"
        case .jeans:        return "rectangle.fill"
        case .dresses:      return "person.fill"
        case .shoes:        return "shoeprints.fill"
        case .accessories:  return "bag.fill"
        case .miscellaneous: return "square.grid.2x2.fill"
        }
    }

    var color: Color {
        switch self {
        case .tops:          return Color("TopsPink",   bundle: nil).opacity(1)
        case .pants:         return Color(hex: "C4D4E8")
        case .jeans:         return Color(hex: "A8BDD4")
        case .dresses:       return Color(hex: "E8C4D8")
        case .shoes:         return Color(hex: "D4C4E8")
        case .accessories:   return Color(hex: "C4E8D8")
        case .miscellaneous: return Color(hex: "E8E4C4")
        }
    }
    
    // Fallback if asset catalog color not used
    var swatchColor: Color {
        switch self {
        case .tops:          return Color(hex: "E8C4C4")
        case .pants:         return Color(hex: "C4D4E8")
        case .jeans:         return Color(hex: "A8BDD4")
        case .dresses:       return Color(hex: "E8C4D8")
        case .shoes:         return Color(hex: "D4C4E8")
        case .accessories:   return Color(hex: "C4E8D8")
        case .miscellaneous: return Color(hex: "E8E4C4")
        }
    }
}

// MARK: - Clothing Item Model
struct ClothingItem: Identifiable, Codable {
    var id: UUID         = UUID()
    var name: String
    var category: ClothingCategory
    var style: String
    var lastWorn: Date?
    var isFavorite: Bool = false
    var imageData: Data?
    var notes: String    = ""

    var lastWornString: String {
        guard let date = lastWorn else { return "Never worn" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
