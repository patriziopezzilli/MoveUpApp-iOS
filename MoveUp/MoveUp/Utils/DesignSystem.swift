import SwiftUI

// MARK: - Color System
extension Color {
    // Accent Colors
    static let moveUpAccent1 = Color(hex: "FB8C00") // Arancione - prenotazioni/alert
    static let moveUpAccent2 = Color(hex: "8E24AA") // Viola - pagamenti/notifiche
    static let moveUpGamification = Color(hex: "FDD835") // Giallo - punti/badge
    static let moveUpEvents = Color(hex: "EC407A") // Rosa - eventi fase 2

    static let moveUpCardBackground = Color.white
    
    // Text Colors
    static let moveUpTextPrimary = Color.black
    static let moveUpTextSecondary = Color.gray
    static let moveUpTextOnDark = Color.white
    
    
    // Helper initializer for hex colors
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
            (a, r, g, b) = (1, 1, 1, 0)
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

// MARK: - Typography System
struct MoveUpFont {
    // Titoli principali - Montserrat Bold equivalent
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    // Sottotitoli - Roboto Medium equivalent
    static func subtitle(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    // Testo descrittivo - Roboto Regular equivalent
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    // Caption text
    static func caption(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    // Button text
    static func button(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
}

// MARK: - Button Styles
struct MoveUpButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var foregroundColor: Color
    var cornerRadius: CGFloat = 12
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MoveUpFont.button())
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct MoveUpSecondaryButtonStyle: ButtonStyle {
    var borderColor: Color
    var foregroundColor: Color
    var cornerRadius: CGFloat = 12
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(MoveUpFont.button())
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card Style
struct MoveUpCardStyle: ViewModifier {
    var backgroundColor: Color = Color.moveUpCardBackground
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 4
    
    func body(content: Content) -> some View {
        content
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }
}

extension View {
    func moveUpCard(
        backgroundColor: Color = Color.moveUpCardBackground,
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4
    ) -> some View {
        self.modifier(MoveUpCardStyle(
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius,
            shadowRadius: shadowRadius
        ))
    }
}

// MARK: - TextField Style
struct MoveUpTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(MoveUpSpacing.medium)
            .background(Color.moveUpCardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.moveUpTextSecondary.opacity(0.3), lineWidth: 1)
            )
            .font(MoveUpFont.body())
            .foregroundColor(Color.moveUpTextPrimary)
    }
}

// MARK: - Spacing System
struct MoveUpSpacing {
    static let xs: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
