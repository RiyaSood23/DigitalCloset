import Foundation

// MARK: - Saved Outfit Model
struct SavedOutfit: Identifiable, Codable {
    var id: UUID          = UUID()
    var name: String
    var itemIDs: [UUID]
    var occasion: Occasion?
    var isFavorite: Bool  = false
    var createdDate: Date = Date()
    var notes: String     = ""
}

// MARK: - Today's Outfit Model
struct TodayOutfit: Codable {
    var date: Date     = Date()
    var itemIDs: [UUID] = []
}
