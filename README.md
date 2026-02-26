# 👗 Digital Closet
### Swift Student Challenge 2026

A beautiful, offline-first wardrobe management app built entirely in SwiftUI.

---

## 📱 Features

### 🗂 Wardrobe (Tab 1)
- Browse your clothes by category — **Tops, Pants, Dresses, Shoes**
- See total item count, outfit count, and favorites at a glance
- Tap any category to view all items in a clean grid
- Tap any item to see full details — style, last worn date, notes
- Add items to **Today's Outfit** directly from the detail view
- Heart ♥ any item to save it to **Favorites**
- A dedicated **Favorites Album** shows all starred items in one place

### ✨ Occasions (Tab 2)
- Filter outfits by occasion — **Casual, Formal, Party**
- View all saved outfits or filter by occasion pill
- Tap any outfit to see items, wear it today, or save to favorites
- **Build a new outfit** from scratch by picking items category by category
- Delete outfits you no longer need

### ☀️ Today (Tab 3)
- Visual **flat-lay layout** showing your outfit for the day
- Add items from any category via the picker sheet
- Remove individual items or clear the whole look
- **Save today's look** as a named outfit to Occasions

### ❤️ Favorites (Tab 4)
- Switch between **Favorite Items** and **Favorite Outfits**
- Everything synced — heart something anywhere in the app and it appears here

---

## 🗂 Project Structure

```
DigitalCloset/
├── DigitalClosetApp.swift          ← App entry point (@main)
├── Media.xcassets                  ← All clothing images live here
├── Helpers/
│   └── Extensions.swift            ← Color(hex:), .darker(), global colors
├── Models/
│   ├── ClothingItem.swift          ← ClothingItem model + ClothingCategory enum
│   ├── Occasion.swift              ← Occasion enum
│   ├── SavedOutfit.swift           ← SavedOutfit + TodayOutfit models
│   └── ClosetStore.swift           ← All data logic (ObservableObject)
└── Views/
    ├── ContentView.swift           ← TabView root
    ├── Shared/
    │   └── SharedComponents.swift  ← Reusable cards, thumbnails, AddItemView
    ├── Categories/
    │   ├── CategoriesView.swift    ← Tab 1 home grid
    │   └── CategoryDetailView.swift← Item grid + detail sheet
    ├── Occasions/
    │   ├── OccasionsView.swift     ← Tab 2 with occasion pills
    │   ├── OutfitDetailView.swift  ← Outfit detail sheet
    │   └── MakeOutfitView.swift    ← Build a new outfit
    ├── Today/
    │   └── TodayOutfitView.swift   ← Tab 3 flat-lay + item picker
    └── Favorites/
        └── FavoritesView.swift     ← Tab 4 favorites
```

---

## 🛠 Setup

1. Open `DigitalCloset.xcodeproj` in Xcode
2. Set deployment target to **iOS 17.0** — Target → General → Minimum Deployments
3. Select a simulator (iPhone 16 Pro recommended)
4. Hit **Run** ▶

No third-party dependencies. No internet required. Everything is offline.

---

## 📦 Tech Stack

| | |
|---|---|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Data Persistence | UserDefaults (JSON encoded) |
| Photo Picker | PhotosUI |
| Minimum iOS | 17.0 |
| Architecture | MVVM (ObservableObject) |

---

## 💾 Data & Storage

All data is saved locally on device using `UserDefaults` with JSON encoding. No accounts, no cloud, no internet connection needed. Your wardrobe data persists between app launches automatically.

---

## ➕ Adding Your Own Items

1. Tap the **+** button in the Wardrobe tab
2. Pick a photo from your gallery
3. Fill in name, category, style, and optional last worn date
4. Tap **Add** — it appears instantly in the right category

---

## 🖼 Adding Images to Sample Data

To wire your asset catalog images into the default sample items, open `ClosetStore.swift` and update `loadSampleData()` — add `imageData: UIImage(named: "your image name")?.jpegData(compressionQuality: 0.8)` to any item.

---

## 👩‍💻 Built For

Apple Swift Student Challenge 2026  
Single developer · SwiftUI · Offline · No dependencies
