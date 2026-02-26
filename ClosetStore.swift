import SwiftUI

// MARK: - Closet Store (Observable Data Layer)
class ClosetStore: ObservableObject {

    @Published var items: [ClothingItem]       = []
    @Published var savedOutfits: [SavedOutfit] = []
    @Published var todayOutfit: TodayOutfit    = TodayOutfit()

    // UserDefaults keys
    private let kItems   = "closet_items"
    private let kOutfits = "closet_outfits"
    private let kToday   = "closet_today"

    init() {
        load()
        if items.isEmpty { loadSampleData() }
    }

    // MARK: - Persistence
    func save() {
        if let d = try? JSONEncoder().encode(items)        { UserDefaults.standard.set(d, forKey: kItems)   }
        if let d = try? JSONEncoder().encode(savedOutfits) { UserDefaults.standard.set(d, forKey: kOutfits) }
        if let d = try? JSONEncoder().encode(todayOutfit)  { UserDefaults.standard.set(d, forKey: kToday)   }
    }

    func load() {
        if let d = UserDefaults.standard.data(forKey: kItems),
           let v = try? JSONDecoder().decode([ClothingItem].self, from: d)  { items        = v }
        if let d = UserDefaults.standard.data(forKey: kOutfits),
           let v = try? JSONDecoder().decode([SavedOutfit].self, from: d)   { savedOutfits = v }
        if let d = UserDefaults.standard.data(forKey: kToday),
           let v = try? JSONDecoder().decode(TodayOutfit.self,   from: d)   { todayOutfit  = v }
    }

    // MARK: - Items CRUD
    func addItem(_ item: ClothingItem) {
        items.append(item)
        save()
    }

    func updateItem(_ item: ClothingItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func deleteItem(_ item: ClothingItem) {
        items.removeAll { $0.id == item.id }
        todayOutfit.itemIDs.removeAll { $0 == item.id }
        for i in savedOutfits.indices {
            savedOutfits[i].itemIDs.removeAll { $0 == item.id }
        }
        save()
    }

    func toggleFavoriteItem(_ item: ClothingItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isFavorite.toggle()
        save()
    }

    func markWornToday(_ item: ClothingItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].lastWorn = Date()
        save()
    }

    // MARK: - Outfits CRUD
    func saveOutfit(_ outfit: SavedOutfit) {
        savedOutfits.append(outfit)
        save()
    }

    func deleteOutfit(_ outfit: SavedOutfit) {
        savedOutfits.removeAll { $0.id == outfit.id }
        save()
    }

    func toggleFavoriteOutfit(_ outfit: SavedOutfit) {
        guard let idx = savedOutfits.firstIndex(where: { $0.id == outfit.id }) else { return }
        savedOutfits[idx].isFavorite.toggle()
        save()
    }

    // MARK: - Today's Outfit
    func addToToday(_ item: ClothingItem) {
        guard !todayOutfit.itemIDs.contains(item.id) else { return }
        todayOutfit.itemIDs.append(item.id)
        save()
    }

    func removeFromToday(_ id: UUID) {
        todayOutfit.itemIDs.removeAll { $0 == id }
        save()
    }

    func clearToday() {
        todayOutfit.itemIDs.removeAll()
        save()
    }

    // MARK: - Computed Helpers
    func items(for category: ClothingCategory) -> [ClothingItem] {
        items.filter { $0.category == category }
    }

    func favoriteItems() -> [ClothingItem] {
        items.filter { $0.isFavorite }
    }

    func favoriteOutfits() -> [SavedOutfit] {
        savedOutfits.filter { $0.isFavorite }
    }

    func todayItems() -> [ClothingItem] {
        todayOutfit.itemIDs.compactMap { id in items.first { $0.id == id } }
    }

    func outfitItems(for outfit: SavedOutfit) -> [ClothingItem] {
        outfit.itemIDs.compactMap { id in items.first { $0.id == id } }
    }

    // MARK: - Sample Data
    private func loadSampleData() {
        let ago: (Int) -> Date? = { Calendar.current.date(byAdding: .day, value: -$0, to: Date()) }

        items = [
            ClothingItem(name: "White Classic Tee",    category: .tops,        style: "Casual",       lastWorn: ago(3),  isFavorite: true),
            ClothingItem(name: "Blue Button-Up",       category: .tops,        style: "Smart Casual", lastWorn: ago(7)),
            ClothingItem(name: "Striped Knit",         category: .tops,        style: "Casual"),
            ClothingItem(name: "Black Blazer",         category: .tops,        style: "Formal",       lastWorn: ago(14), isFavorite: true),
            ClothingItem(name: "Slim Chinos",          category: .pants,       style: "Smart Casual", lastWorn: ago(2)),
            ClothingItem(name: "Wide Leg Trousers",    category: .pants,       style: "Casual"),
            ClothingItem(name: "Straight Leg Jeans",   category: .jeans,       style: "Casual",       lastWorn: ago(1),  isFavorite: true),
            ClothingItem(name: "Dark Wash Jeans",      category: .jeans,       style: "Smart Casual"),
            ClothingItem(name: "Floral Midi Dress",    category: .dresses,     style: "Party",        lastWorn: ago(30), isFavorite: true),
            ClothingItem(name: "White Sundress",       category: .dresses,     style: "Casual"),
            ClothingItem(name: "White Sneakers",       category: .shoes,       style: "Casual",       lastWorn: ago(1)),
            ClothingItem(name: "Classic Loafers",      category: .shoes,       style: "Smart Casual", lastWorn: ago(5)),
            ClothingItem(name: "Heeled Boots",         category: .shoes,       style: "Formal",       lastWorn: ago(20), isFavorite: true),
            ClothingItem(name: "Leather Belt",         category: .accessories, style: "Formal"),
            ClothingItem(name: "Silk Scarf",           category: .accessories, style: "Casual",       isFavorite: true),
            ClothingItem(name: "Gold Hoop Earrings",   category: .accessories, style: "Party"),
        ]

        savedOutfits = [
            SavedOutfit(name: "Weekend Casual",  itemIDs: [items[0].id, items[6].id,  items[10].id], occasion: .casual,  isFavorite: true),
            SavedOutfit(name: "Office Ready",    itemIDs: [items[3].id, items[4].id,  items[11].id], occasion: .work),
            SavedOutfit(name: "Night Out",       itemIDs: [items[8].id, items[12].id, items[15].id], occasion: .party,   isFavorite: true),
            SavedOutfit(name: "Smart Friday",    itemIDs: [items[1].id, items[7].id,  items[11].id], occasion: .formal),
        ]

        save()
    }
}
