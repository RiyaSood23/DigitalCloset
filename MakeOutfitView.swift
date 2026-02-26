import SwiftUI

// ============================================================
// MARK: - Make / Build Outfit Sheet
// ============================================================
struct MakeOutfitView: View {
    @EnvironmentObject var store: ClosetStore
    @Environment(\.dismiss) var dismiss

    var preselectedOccasion: Occasion? = nil

    @State private var outfitName       = ""
    @State private var selectedOccasion: Occasion? = nil
    @State private var selectedIDs      = Set<UUID>()
    @State private var selectedCategory = ClothingCategory.tops

    private var canSave: Bool { !outfitName.trimmingCharacters(in: .whitespaces).isEmpty && !selectedIDs.isEmpty }

    var body: some View {
        NavigationStack {
            Form {

                // ── Name & occasion ────────────────────────────
                Section("Outfit Details") {
                    TextField("Give this outfit a name", text: $outfitName)

                    Picker("Occasion", selection: $selectedOccasion) {
                        Text("No occasion").tag(Optional<Occasion>.none)
                        ForEach(Occasion.allCases) { occ in
                            Label(occ.rawValue, systemImage: occ.icon)
                                .tag(Optional(occ))
                        }
                    }
                }

                // ── Category picker & item list ────────────────
                Section {
                    // Inline scrollable category row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ClothingCategory.allCases) { cat in
                                Button {
                                    selectedCategory = cat
                                } label: {
                                    Text(cat.rawValue)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 12).padding(.vertical, 7)
                                        .background(selectedCategory == cat ? Color.appPurple : Color.gray.opacity(0.1))
                                        .foregroundStyle(selectedCategory == cat ? .white : .primary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Select Items")
                }

                // Item rows for selected category
                Section {
                    let catItems = store.items(for: selectedCategory)
                    if catItems.isEmpty {
                        Text("No items in \(selectedCategory.rawValue)")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(catItems) { item in
                            ItemPickerRow(item: item, isSelected: selectedIDs.contains(item.id)) {
                                if selectedIDs.contains(item.id) { selectedIDs.remove(item.id) }
                                else                             { selectedIDs.insert(item.id) }
                            }
                        }
                    }
                }

                // ── Selected preview strip ─────────────────────
                if !selectedIDs.isEmpty {
                    Section("Selected — \(selectedIDs.count) item\(selectedIDs.count == 1 ? "" : "s")") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(selectedIDs), id: \.self) { id in
                                    if let item = store.items.first(where: { $0.id == id }) {
                                        VStack(spacing: 4) {
                                            ItemThumb(item: item, size: 56)
                                            Text(item.name)
                                                .font(.caption2)
                                                .lineLimit(1)
                                                .frame(width: 56)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("New Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveOutfit() }
                        .bold()
                        .foregroundStyle(canSave ? Color.appPurple : .gray)
                        .disabled(!canSave)
                }
            }
            .onAppear { selectedOccasion = preselectedOccasion }
        }
    }

    private func saveOutfit() {
        let outfit = SavedOutfit(
            name:     outfitName.trimmingCharacters(in: .whitespaces),
            itemIDs:  Array(selectedIDs),
            occasion: selectedOccasion
        )
        store.saveOutfit(outfit)
        dismiss()
    }
}

// ============================================================
// MARK: - Item Picker Row
// ============================================================
struct ItemPickerRow: View {
    let item: ClothingItem
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ItemThumb(item: item, size: 46)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(.subheadline.bold())
                Text(item.style).font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Image(
                systemName: isSelected ? "checkmark.circle.fill" : "circle"
            )
            .foregroundStyle(isSelected ? Color.appPurple : .gray.opacity(0.4))
            .font(.title3)
        }
        .contentShape(Rectangle())
        .onTapGesture { onToggle() }
    }
}

#Preview {
    MakeOutfitView()
        .environmentObject(ClosetStore())
}
