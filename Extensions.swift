import SwiftUI

// MARK: - Global Design Tokens
extension Color {
    static let appPurple  = Color(hex: "9B7EBD")   // primary accent
    static let appPink    = Color(hex: "E8A0BF")   // hearts / favorites
    static let appBg      = Color(hex: "FAF8FF")   // background
    static let appCard    = Color.white
}

// MARK: - Hex Color Init
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Returns a darker shade of this color
    func darker(by amount: Double = 0.2) -> Color {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(
            UIColor(
                hue:        h,
                saturation: min(s + CGFloat(amount), 1.0),
                brightness: max(b - CGFloat(amount), 0.0),
                alpha:      a
            )
        )
    }
}
