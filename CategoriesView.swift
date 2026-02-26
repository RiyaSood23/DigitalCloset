import SwiftUI

struct CategoriesView: View {
    @EnvironmentObject var store: ClosetStore
    @State private var showAddItem = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // ── Stats bar ──────────────────────────────
                    HStack(spacing: 12) {
                        StatCard(value: "\(store.items.count)",
                                 label: "Items",
                                 icon: "tshirt",
                                 color: Color.appPurple)
                        StatCard(value: "\(store.savedOutfits.count)",
                                 label: "Outfits",
                                 icon: "sparkles",
                                 color: Color.appPink)
                        StatCard(value: "\(store.favoriteItems().count)",
                                 label: "Favorites",
                                 icon: "heart.fill",
                                 color: .orange)
                    }
                    .padding(.horizontal)

                    // ── Category grid ──────────────────────────
                    Text("Categories")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(ClothingCategory.allCases) { category in
                            NavigationLink(
                                destination: CategoryDetailView(category: category)
                            ) {
                                CategoryCard(
                                    category: category,
                                    count: store.items(for: category).count
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        // ── Favorites album card ───────────────
                        NavigationLink(destination: FavoritesItemsView()) {
                            FavoritesAlbumCard(count: store.favoriteItems().count)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
            .background(Color.appBg)
            .navigationTitle("My Closet")
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
                AddItemView()
            }
        }
    }
}

// ============================================================
// MARK: - Stat Card
// ============================================================
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

// ============================================================
// MARK: - Category Card
// ============================================================
struct CategoryCard: View {
    let category: ClothingCategory
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(category.swatchColor.opacity(0.3))
                        .frame(width: 42, height: 42)
                    Image(systemName: category.icon)
                        .font(.headline)
                        .foregroundStyle(category.swatchColor.darker())
                }
                Spacer()
                Text("\(count)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
            }
            Text(category.rawValue).font(.headline)
            Text(count == 1 ? "1 item" : "\(count) items")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

// ============================================================
// MARK: - Favorites Album Card
// ============================================================
struct FavoritesAlbumCard: View {
    let count: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.appPink.opacity(0.25))
                        .frame(width: 42, height: 42)
                    Image(systemName: "heart.fill")
                        .font(.headline)
                        .foregroundStyle(Color.appPink)
                }
                Spacer()
                Text("\(count)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(Capsule())
            }
            Text("Favorites").font(.headline)
            Text(count == 1 ? "1 item" : "\(count) items")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(hex: "FFF0F5"), .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appPink.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}

#Preview {
    CategoriesView()
        .environmentObject(ClosetStore())
}
