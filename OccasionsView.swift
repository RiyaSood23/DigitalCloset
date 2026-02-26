import SwiftUI

// ============================================================
// MARK: - Occasions Home (Tab 2)
// ============================================================
struct OccasionsView: View {
    @EnvironmentObject var store: ClosetStore

    @State private var selectedOccasion: Occasion? = nil
    @State private var showMakeOutfit              = false

    private var filteredOutfits: [SavedOutfit] {
        guard let occ = selectedOccasion else { return store.savedOutfits }
        return store.savedOutfits.filter { $0.occasion == occ }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // ── Occasion pills ──────────────────────────
                    Text("Choose Occasion")
                        .font(.title2.bold())
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Occasion.allCases) { occ in
                                OccasionPill(
                                    occasion: occ,
                                    isSelected: selectedOccasion == occ
                                )
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedOccasion = (selectedOccasion == occ) ? nil : occ
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // ── Outfits section header ──────────────────
                    HStack {
                        Text(selectedOccasion == nil
                             ? "All Outfits"
                             : "\(selectedOccasion!.rawValue) Outfits")
                            .font(.title2.bold())
                        Spacer()
                        Button { showMakeOutfit = true } label: {
                            Label("New Outfit", systemImage: "plus.circle.fill")
                                .font(.subheadline.bold())
                                .foregroundStyle(Color.appPurple)
                        }
                    }
                    .padding(.horizontal)

                    // ── Outfit list ─────────────────────────────
                    if filteredOutfits.isEmpty {
                        EmptyStateView(
                            icon: "sparkles",
                            title: "No outfits yet",
                            subtitle: "Create your first outfit for this occasion",
                            color: selectedOccasion?.color ?? Color.appPurple
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(filteredOutfits) { outfit in
                                OutfitCardNavigable(outfit: outfit)
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 10)
            }
            .background(Color.appBg)
            .navigationTitle("Occasions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showMakeOutfit = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.appPurple)
                    }
                }
            }
            .sheet(isPresented: $showMakeOutfit) {
                MakeOutfitView(preselectedOccasion: selectedOccasion)
            }
        }
    }
}

// ============================================================
// MARK: - Occasion Pill Button
// ============================================================
struct OccasionPill: View {
    let occasion: Occasion
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: occasion.icon).font(.subheadline)
            Text(occasion.rawValue).font(.subheadline.bold())
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
        .background(isSelected ? occasion.color : occasion.color.opacity(0.18))
        .foregroundStyle(isSelected ? .white : .primary)
        .clipShape(Capsule())
        .shadow(color: isSelected ? occasion.color.opacity(0.45) : .clear, radius: 8, y: 3)
    }
}

// ============================================================
// MARK: - Outfit Card with Navigation to Detail
// ============================================================
struct OutfitCardNavigable: View {
    @EnvironmentObject var store: ClosetStore
    let outfit: SavedOutfit
    @State private var showDetail = false

    var body: some View {
        OutfitCard(outfit: outfit) { showDetail = true }
            .sheet(isPresented: $showDetail) {
                OutfitDetailView(outfit: outfit)
            }
    }
}

#Preview {
    OccasionsView()
        .environmentObject(ClosetStore())
}
