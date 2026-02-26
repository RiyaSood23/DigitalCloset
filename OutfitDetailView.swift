import SwiftUI

// ============================================================
// MARK: - Outfit Detail Sheet
// ============================================================
struct OutfitDetailView: View {
    @EnvironmentObject var store: ClosetStore
    @Environment(\.dismiss) var dismiss

    let outfit: SavedOutfit

    @State private var showDelete = false

    private var outfitItems: [ClothingItem] { store.outfitItems(for: outfit) }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Occasion badge ─────────────────────────
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(outfit.occasion?.color.opacity(0.2) ?? Color.gray.opacity(0.1))
                                .frame(width: 72, height: 72)
                            Image(systemName: outfit.occasion?.icon ?? "sparkles")
                                .font(.largeTitle)
                                .foregroundStyle(outfit.occasion?.color.darker() ?? .gray)
                        }
                        Text(outfit.name).font(.title2.bold())
                        if let occ = outfit.occasion {
                            Text(occ.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 14).padding(.vertical, 6)
                                .background(occ.color.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.top, 4)

                    // ── Item grid ──────────────────────────────
                    if outfitItems.isEmpty {
                        Text("No items in this outfit")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(outfitItems) { item in
                                OutfitItemTile(item: item)
                            }
                        }
                        .padding(.horizontal)
                    }

                    // ── Action buttons ─────────────────────────
                    VStack(spacing: 10) {
                        // Wear today
                        Button {
                            outfitItems.forEach { store.addToToday($0) }
                            dismiss()
                        } label: {
                            Label("Wear Today", systemImage: "sun.max.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appPurple)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .font(.headline)
                        }

                        // Favourite toggle
                        Button { store.toggleFavoriteOutfit(outfit) } label: {
                            Label(
                                outfit.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                systemImage: outfit.isFavorite ? "heart.slash" : "heart.fill"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appPink.opacity(0.15))
                            .foregroundStyle(Color.appPink.darker())
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // Delete
                        Button { showDelete = true } label: {
                            Label("Delete Outfit", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.08))
                                .foregroundStyle(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
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
            .alert("Delete Outfit", isPresented: $showDelete) {
                Button("Delete", role: .destructive) { store.deleteOutfit(outfit); dismiss() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Delete \"\(outfit.name)\"?")
            }
        }
    }
}

// ============================================================
// MARK: - Item tile inside outfit detail
// ============================================================
struct OutfitItemTile: View {
    let item: ClothingItem

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(item.category.swatchColor.opacity(0.2))
                    .frame(height: 110)

                if let data = item.imageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: item.category.icon)
                        .font(.largeTitle)
                        .foregroundStyle(item.category.swatchColor.darker())
                }
            }
            Text(item.name)
                .font(.caption.bold())
                .lineLimit(1)
            Text(item.category.rawValue)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
}
