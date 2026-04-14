import SwiftUI

struct AppDesign {
    // Backgrounds (Dynamic from Assets)
    static let bgMain = Color("bgMain")
    static let surface = Color("surface")
    
    // Duolingo Primary Colors (Static)
    static let green = Color(hex: "58CC02")
    static let greenShadow = Color(hex: "58A700")
    
    static let blue = Color(hex: "1CB0F6")
    static let blueShadow = Color(hex: "1899D6")
    
    static let red = Color(hex: "FF4B4B")
    static let redShadow = Color(hex: "EA2B2B")
    
    static let orange = Color(hex: "FF9600")
    
    static let yellow = Color(hex: "FFC800")
    
    // Borders (Dynamic from Assets)
    static let border = Color("border")
    
    // Text (Dynamic from Assets)
    static let textMain = Color("textMain")
    static let textSecondary = Color("textSecondary")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Duolingo Card Modifier
struct DuolingoCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppDesign.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppDesign.border, lineWidth: 2)
            )
            .shadow(color: AppDesign.border, radius: 0, x: 0, y: 4)
    }
}

extension View {
    func duolingoCard() -> some View {
        self.modifier(DuolingoCardModifier())
    }
    
    func premiumCard() -> some View {
        self.modifier(DuolingoCardModifier())
    }
}

// Duolingo Button Style
struct DuolingoButtonStyle: ButtonStyle {
    var color: Color
    var shadowColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(color)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color, lineWidth: 2)
            )
            .padding(.bottom, configuration.isPressed ? 0 : 4)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(shadowColor)
            )
            .offset(y: configuration.isPressed ? 4 : 0)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct DuolingoGhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(AppDesign.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppDesign.border, lineWidth: 2)
            )
            .padding(.bottom, configuration.isPressed ? 0 : 4)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppDesign.border)
            )
            .offset(y: configuration.isPressed ? 4 : 0)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
