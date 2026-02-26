import SwiftUI

// ============================================================
// MARK: - Favorites (Tab 4)
// ============================================================
struct FavoritesView: View {
    @EnvironmentObject var store: ClosetStore
    @State private var selectedSegment = 0

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Segment control
                Picker("", selection: $selectedSegment) {
                    Text("Items").tag(0)
                    Text("Outfits").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                if selectedSegment == 0 {
                    favoriteItemsGrid
                } else {
                    favoriteOutfitsList
                }
            }
            .background(Color.appBg)
            .navigationTitle("Favorites")
        }
    }

    // ── Favorite items grid ────────────────────────────────────
    @ViewBuilder
    private var favoriteItemsGrid: some View {
        if store.favoriteItems().isEmpty {
            Spacer()
            EmptyStateView(
                icon: "heart",
                title: "No favorite items",
                subtitle: "Tap ♥ on any item in your wardrobe to save it here",
                color: Color.appPink
            )
            Spacer()
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(store.favoriteItems()) { item in
                        FavoriteItemCard(item: item)
                    }
                }
                .padding()
            }
        }
    }

    // ── Favorite outfits list ──────────────────────────────────
    @ViewBuilder
    private var favoriteOutfitsList: some View {
        if store.favoriteOutfits().isEmpty {
            Spacer()
            EmptyStateView(
                icon: "heart",
                title: "No favorite outfits",
                subtitle: "Tap ♥ on any outfit to save it here",
                color: Color.appPink
            )
            Spacer()
        } else {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(store.favoriteOutfits()) { outfit in
                        OutfitCardNavigable(outfit: outfit)
                    }
                }
                .padding()
            }
        }
    }
}

// ============================================================
// MARK: - Favorite Item Card (tappable with detail sheet)
// ============================================================
struct FavoriteItemCard: View {
    @EnvironmentObject var store: ClosetStore
    let item: ClothingItem
    @State private var showDetail = false

    var body: some View {
        ClothingItemCard(item: item) { showDetail = true }
            .sheet(isPresented: $showDetail) {
                ItemDetailView(item: item)
            }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(ClosetStore())
}
