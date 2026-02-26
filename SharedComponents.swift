import SwiftUI
import PhotosUI

// ============================================================
// MARK: - Empty State
// ============================================================
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 90, height: 90)
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundStyle(color.darker())
            }
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// ============================================================
// MARK: - Item Thumbnail (icon or photo, any size)
// ============================================================
struct ItemThumb: View {
    let item: ClothingItem
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(item.category.swatchColor.opacity(0.25))
                .frame(width: size, height: size)

            if let data = item.imageData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size * 0.18))
            } else {
                VStack(spacing: 3) {
                    Image(systemName: item.category.icon)
                        .font(size > 70 ? .title2 : .callout)
                        .foregroundStyle(item.category.swatchColor.darker())
                    if size > 55 {
                        Text(item.name)
                            .font(.system(size: min(size * 0.12, 11)))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .frame(width: size - 10)
                    }
                }
            }
        }
    }
}

// ============================================================
// MARK: - Clothing Item Card (grid tile)
// ============================================================
struct ClothingItemCard: View {
    @EnvironmentObject var store: ClosetStore
    let item: ClothingItem
    var onTap: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // Photo / Icon area
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.category.swatchColor.opacity(0.2))
                        .frame(height: 100)

                    if let data = item.imageData, let ui = UIImage(data: data) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: item.category.icon)
                                .font(.title2)
                                .foregroundStyle(item.category.swatchColor.darker())
                            Text(item.name)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .padding(.horizontal, 4)
                        }
                    }
                }

                // Label
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.caption.bold())
                        .lineLimit(1)
                    Text(item.style)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 6)
                .padding(.vertical, 5)
            }
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.07), radius: 6, y: 2)
            .onTapGesture { onTap?() }

            // Favorite heart
            Button { store.toggleFavoriteItem(item) } label: {
                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                    .font(.caption)
                    .foregroundStyle(item.isFavorite ? Color.appPink : .gray)
                    .padding(6)
                    .background(.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 3)
            }
            .padding(6)
        }
    }
}

// ============================================================
// MARK: - Outfit Card (list row)
// ============================================================
struct OutfitCard: View {
    @EnvironmentObject var store: ClosetStore
    let outfit: SavedOutfit
    var onTap: (() -> Void)? = nil

    private var oItems: [ClothingItem] { store.outfitItems(for: outfit) }

    var body: some View {
        HStack(spacing: 14) {
            // Mini preview
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(outfit.occasion?.color.opacity(0.2) ?? Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)

                ForEach(Array(oItems.prefix(3).enumerated()), id: \.element.id) { idx, item in
                    Image(systemName: item.category.icon)
                        .font(.title3)
                        .foregroundStyle(item.category.swatchColor.darker())
                        .frame(width: 30, height: 30)
                        .background(item.category.swatchColor.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .offset(x: CGFloat(idx - 1) * 12, y: CGFloat(idx - 1) * 8)
                }
            }

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(outfit.name).font(.headline)
                    Spacer()
                    Button { store.toggleFavoriteOutfit(outfit) } label: {
                        Image(systemName: outfit.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(outfit.isFavorite ? Color.appPink : .gray)
                    }
                }
                if let occ = outfit.occasion {
                    Label(occ.rawValue, systemImage: occ.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("\(oItems.count) item\(oItems.count == 1 ? "" : "s")")
                    .font(.caption2)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .onTapGesture { onTap?() }
    }
}

// ============================================================
// MARK: - Add / Edit Item Sheet
// ============================================================
struct AddItemView: View {
    @EnvironmentObject var store: ClosetStore
    @Environment(\.dismiss) var dismiss

    var preselectedCategory: ClothingCategory? = nil
    var existingItem: ClothingItem?             = nil

    @State private var name        = ""
    @State private var category    = ClothingCategory.tops
    @State private var style       = ""
    @State private var notes       = ""
    @State private var lastWorn    = Date()
    @State private var hasLastWorn = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil

    let styleOptions = ["Casual", "Smart Casual", "Formal", "Party", "Sporty", "Boho", "Vintage", "Minimalist"]
    var isEditing: Bool { existingItem != nil }

    var body: some View {
        NavigationStack {
            Form {
                // --- Photo ---
                Section("Photo") {
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(category.swatchColor.opacity(0.2))
                                .frame(width: 130, height: 130)

                            if let data = imageData, let ui = UIImage(data: data) {
                                Image(uiImage: ui)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 130, height: 130)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                VStack(spacing: 6) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.largeTitle)
                                        .foregroundStyle(Color.appPurple)
                                    Text("Add Photo")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .overlay(alignment: .bottomTrailing) {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Color.appPurple)
                                    .background(.white)
                                    .clipShape(Circle())
                            }
                            .padding(4)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                // --- Details ---
                Section("Details") {
                    TextField("Item name", text: $name)

                    Picker("Category", selection: $category) {
                        ForEach(ClothingCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }

                    Picker("Style", selection: $style) {
                        Text("Select a style").tag("")
                        ForEach(styleOptions, id: \.self) { s in Text(s).tag(s) }
                    }
                }

                // --- Last Worn ---
                Section("Last Worn") {
                    Toggle("Set last worn date", isOn: $hasLastWorn)
                    if hasLastWorn {
                        DatePicker("Date", selection: $lastWorn, displayedComponents: .date)
                    }
                }

                // --- Notes ---
                Section("Notes") {
                    TextField("Optional notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Save" : "Add") { saveItem() }
                        .bold()
                        .foregroundStyle(canSave ? Color.appPurple : .gray)
                        .disabled(!canSave)
                }
            }
            
            .task(id: selectedPhoto) {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }            .onAppear { populateIfEditing() }
        }
    }

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty && !style.isEmpty }

    private func populateIfEditing() {
        if let p = preselectedCategory { category = p }
        guard let e = existingItem else { return }
        name      = e.name
        category  = e.category
        style     = e.style
        notes     = e.notes
        imageData = e.imageData
        if let lw = e.lastWorn { hasLastWorn = true; lastWorn = lw }
    }

    private func saveItem() {
        var item       = existingItem ?? ClothingItem(name: name, category: category, style: style)
        item.name      = name.trimmingCharacters(in: .whitespaces)
        item.category  = category
        item.style     = style
        item.notes     = notes
        item.imageData = imageData
        item.lastWorn  = hasLastWorn ? lastWorn : nil

        if isEditing { store.updateItem(item) } else { store.addItem(item) }
        dismiss()
    }
}
