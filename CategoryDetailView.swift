import SwiftUI

// ============================================================
// MARK: - Category Detail (grid of items in one category)
// ============================================================
struct CategoryDetailView: View {
    @EnvironmentObject var store: ClosetStore
    let category: ClothingCategory

    @State private var showAddItem   = false
    @State private var selectedItem: ClothingItem? = nil

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private var categoryItems: [ClothingItem] { store.items(for: category) }

    var body: some View {
        ScrollView {
            if categoryItems.isEmpty {
                EmptyStateView(
                    icon: category.icon,
                    title: "No \(category.rawValue) yet",
                    subtitle: "Tap + to add your first item",
                    color: category.swatchColor
                )
                .padding(.top, 80)
                .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(categoryItems) { item in
                        ClothingItemCard(item: item) {
                            selectedItem = item
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.appBg)
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showAddItem = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appPurple)
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddItemView(preselectedCategory: category)
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(item: item)
        }
    }
}

// ============================================================
// MARK: - Item Detail Sheet
// ============================================================
struct ItemDetailView: View {
    @EnvironmentObject var store: ClosetStore
    @Environment(\.dismiss) var dismiss

    var item: ClothingItem

    @State private var showEdit   = false
    @State private var showDelete = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Hero image ─────────────────────────────
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(item.category.swatchColor.opacity(0.2))
                            .frame(height: 250)

                        if let data = item.imageData, let ui = UIImage(data: data) {
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: item.category.icon)
                                    .font(.system(size: 64))
                                    .foregroundStyle(item.category.swatchColor.darker())
                                Text("No photo added")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // ── Detail card ────────────────────────────
                    VStack(alignment: .leading, spacing: 18) {
                        // Name + favourite
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name).font(.title2.bold())
                                Label(item.category.rawValue, systemImage: item.category.icon)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button { store.toggleFavoriteItem(item) } label: {
                                Image(systemName: item.isFavorite ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundStyle(item.isFavorite ? Color.appPink : .gray)
                            }
                        }

                        Divider()

                        // Meta rows
                        DetailInfoRow(icon: "tag.fill",       label: "Style",     value: item.style)
                        DetailInfoRow(icon: "calendar",       label: "Last Worn", value: item.lastWornString)
                        if !item.notes.isEmpty {
                            DetailInfoRow(icon: "note.text",  label: "Notes",     value: item.notes)
                        }

                        Divider()

                        // ── Actions ────────────────────────────
                        Button {
                            store.addToToday(item)
                            store.markWornToday(item)
                            dismiss()
                        } label: {
                            Label("Add to Today's Outfit", systemImage: "sun.max.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appPurple)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .font(.headline)
                        }

                        HStack(spacing: 10) {
                            Button { showEdit = true } label: {
                                Label("Edit", systemImage: "pencil")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            Button { showDelete = true } label: {
                                Label("Delete", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .foregroundStyle(.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    .padding()
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.06), radius: 10, y: 2)
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
            .background(Color.appBg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.appPurple)
                }
            }
            .alert("Delete Item", isPresented: $showDelete) {
                Button("Delete", role: .destructive) { store.deleteItem(item); dismiss() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete \"\(item.name)\"?")
            }
            .sheet(isPresented: $showEdit) {
                AddItemView(existingItem: item)
            }
        }
    }
}

// ============================================================
// MARK: - Detail Info Row
// ============================================================
struct DetailInfoRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(Color.appPurple)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .multilineTextAlignment(.trailing)
        }
    }
}

// ============================================================
// MARK: - Favorites Items View (linked from album card)
// ============================================================
struct FavoritesItemsView: View {
    @EnvironmentObject var store: ClosetStore

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            if store.favoriteItems().isEmpty {
                EmptyStateView(
                    icon: "heart",
                    title: "No favorite items",
                    subtitle: "Tap ♥ on any clothing item to save it here",
                    color: Color.appPink
                )
                .padding(.top, 80)
                .frame(maxWidth: .infinity)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(store.favoriteItems()) { item in
                        ClothingItemCard(item: item)
                    }
                }
                .padding()
            }
        }
        .background(Color.appBg)
        .navigationTitle("Favorite Items")
    }
}

#Preview {
    NavigationStack {
        CategoryDetailView(category: .tops)
            .environmentObject(ClosetStore())
    }
}
