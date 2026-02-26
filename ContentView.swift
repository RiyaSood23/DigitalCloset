import SwiftUI

struct ContentView: View {
    @StateObject private var store = ClosetStore()

    var body: some View {
        TabView {
            CategoriesView()
                .tabItem { Label("Wardrobe",  systemImage: "tshirt.fill")   }

            OccasionsView()
                .tabItem { Label("Occasions", systemImage: "sparkles")       }

            TodayOutfitView()
                .tabItem { Label("Today",     systemImage: "sun.max.fill")   }

            FavoritesView()
                .tabItem { Label("Favorites", systemImage: "heart.fill")     }
        }
        .tint(Color.appPurple)
        .environmentObject(store)
    }
}

#Preview {
    ContentView()
}
