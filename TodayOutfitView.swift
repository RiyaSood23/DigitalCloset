import SwiftUI

// ============================================================
// MARK: - Today's Outfit (Tab 3)
// ============================================================
struct TodayOutfitView: View {
    @EnvironmentObject var store: ClosetStore
    @State private var showPicker       = false
    @State private var showSaveConfirm  = false

    private var todayItems: [ClothingItem] { store.todayItems() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {

                    // ── Date header ────────────────────────────
                    dateHeader

                    if todayItems.isEmpty {
                        // ── Empty state ────────────────────────
                        emptyState
                    } else {
                        // ── Flat-lay preview ───────────────────
                        OutfitFlatLayView(items: todayItems)
                            .padding(.horizontal)

                        // ── Item list ──────────────────────────
                        itemList

                        // ── Secondary actions ──────────────────
                        secondaryActions
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 24)
            }
            .background(Color.appBg)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !todayItems.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") {
                            withAnimation { store.clearToday() }
                        }
                        .foregroundStyle(.red)
                    }
                }
            }
            .sheet(isPresented: $showPicker) { TodayItemPickerView() }
            .alert("Outfit Saved!", isPresented: $showSaveConfirm) {
                Button("OK") {}
            } message: {
                Text("Your look has been saved to Occasions.")
            }
        }
    }

    // ── Sub-views ─────────────────────────────────────────────
    private var dateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Look")
                    .font(.title.bold())
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.18))
                    .frame(width: 54, height: 54)
                Image(systemName: "sun.max.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 28) {
            EmptyStateView(
                icon: "hanger",
                title: "No outfit planned",
                subtitle: "Add items from your wardrobe to build today's look",
                color: Color.appPurple
            )
            .padding(.top, 40)

            Button { showPicker = true } label: {
                Label("Build Today's Outfit", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appPurple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 32)
            }
        }
    }

    private var itemList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items in Today's Outfit")
                .font(.headline)
                .padding(.horizontal)

            ForEach(todayItems) { item in
                TodayItemRow(item: item)
                    .padding(.horizontal)
            }
        }
    }

    private var secondaryActions: some View {
        VStack(spacing: 10) {
            Button { showPicker = true } label: {
                Label("Add More Items", systemImage: "plus.circle")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .foregroundStyle(.primary)

            Button { saveCurrentLook() } label: {
                Label("Save as Outfit", systemImage: "bookmark.fill")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.appPurple.opacity(0.15))
                    .foregroundStyle(Color.appPurple.darker())
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal)
    }

    private func saveCurrentLook() {
        let outfit = SavedOutfit(
            name: "Look — \(Date().formatted(date: .abbreviated, time: .omitted))",
            itemIDs: store.todayOutfit.itemIDs,
            occasion: .casual
        )
        store.saveOutfit(outfit)
        showSaveConfirm = true
    }
}

// ============================================================
// MARK: - Flat-lay Preview
// ============================================================
struct OutfitFlatLayView: View {
    let items: [ClothingItem]

    private var top:        ClothingItem? { items.first { $0.category == .tops || $0.category == .dresses } }
    private var bottom:     ClothingItem? { items.first { $0.category == .pants || $0.category == .jeans } }
    private var shoes:      ClothingItem? { items.first { $0.category == .shoes } }
    private var extras:    [ClothingItem] { items.filter { $0.category == .accessories || $0.category == .miscellaneous } }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "F3EEFF"))
                .frame(height: 300)

            VStack(spacing: 10) {
                if let t = top    { ItemThumb(item: t, size: 88)  }
                if let b = bottom { ItemThumb(item: b, size: 78)  }
                HStack(spacing: 14) {
                    if let s = shoes { ItemThumb(item: s, size: 62) }
                    ForEach(extras.prefix(2)) { item in ItemThumb(item: item, size: 50) }
                }
            }
        }
    }
}

// ============================================================
// MARK: - Today Item Row
// ============================================================
struct TodayItemRow: View {
    @EnvironmentObject var store: ClosetStore
    let item: ClothingItem

    var body: some View {
        HStack(spacing: 12) {
            ItemThumb(item: item, size: 50)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.subheadline.bold())
                Text(item.category.rawValue).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Button { store.removeFromToday(item.id) } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.gray.opacity(0.5))
            }
        }
        .padding(12)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
}

// ============================================================
// MARK: - Today Item Picker Sheet
// ============================================================
struct TodayItemPickerView: View {
    @EnvironmentObject var store: ClosetStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory = ClothingCategory.tops

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ClothingCategory.allCases) { cat in
                            Button { selectedCategory = cat } label: {
                                Text(cat.rawValue)
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(selectedCategory == cat ? Color.appPurple : Color.gray.opacity(0.1))
                                    .foregroundStyle(selectedCategory == cat ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                }

                Divider()

                let catItems = store.items(for: selectedCategory)

                if catItems.isEmpty {
                    Spacer()
                    EmptyStateView(
                        icon: selectedCategory.icon,
                        title: "No \(selectedCategory.rawValue)",
                        subtitle: "Add items from the Wardrobe tab first",
                        color: selectedCategory.swatchColor
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(catItems) { item in
                                PickerRow(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color.appBg)
            .navigationTitle("Add to Today")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .bold()
                        .foregroundStyle(Color.appPurple)
                }
            }
        }
    }
}

// ============================================================
// MARK: - Picker Row (inside picker sheet)
// ============================================================
private struct PickerRow: View {
    @EnvironmentObject var store: ClosetStore
    let item: ClothingItem

    private var isAdded: Bool { store.todayOutfit.itemIDs.contains(item.id) }

    var body: some View {
        HStack(spacing: 12) {
            ItemThumb(item: item, size: 52)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.subheadline.bold())
                Text(item.lastWornString).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                if isAdded {
                    store.removeFromToday(item.id)
                } else {
                    store.addToToday(item)
                    store.markWornToday(item)
                }
            } label: {
                Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                    .foregroundStyle(isAdded ? Color.appPurple : .gray)
                    .font(.title2)
            }
        }
        .padding(12)
        .background(Color.appCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 1)
    }
}

#Preview {
    TodayOutfitView()
        .environmentObject(ClosetStore())
}
