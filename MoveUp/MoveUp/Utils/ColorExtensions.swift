import SwiftUI

// MARK: - Color Extensions for MoveUp Brand
extension Color {
    // Primary Colors
    static let moveUpPrimary = Color(red: 0.2, green: 0.6, blue: 1.0) // #3399FF - Blu principale
    static let moveUpSecondary = Color(red: 0.0, green: 0.8, blue: 0.4) // #00CC66 - Verde accento
    static let moveUpAccent = Color(red: 1.0, green: 0.6, blue: 0.0) // #FF9900 - Arancione per CTA
    
    // Background Colors
    static let moveUpBackground = Color(UIColor.systemBackground) // Sfondo principale
    static let moveUpSurface = Color(UIColor.secondarySystemBackground) // Superfici elevate
    static let moveUpCard = Color(UIColor.tertiarySystemBackground) // Sfondo card
    
    // Text Colors
    static let moveUpTextTertiary = Color(UIColor.tertiaryLabel) // Testo terziario
    
    // State Colors
    static let moveUpSuccess = Color(red: 0.2, green: 0.8, blue: 0.2) // #33CC33 - Verde successo
    static let moveUpWarning = Color(red: 1.0, green: 0.8, blue: 0.0) // #FFCC00 - Giallo warning
    static let moveUpError = Color(red: 1.0, green: 0.3, blue: 0.3) // #FF4D4D - Rosso errore
    static let moveUpInfo = Color(red: 0.3, green: 0.7, blue: 1.0) // #4DB3FF - Blu informativo
}

// MARK: - Gradient Extensions
extension LinearGradient {
    static var moveUpPrimaryGradient: LinearGradient {
        LinearGradient(
            colors: [Color.moveUpPrimary, Color.moveUpSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var moveUpAccentGradient: LinearGradient {
        LinearGradient(
            colors: [Color.moveUpAccent, Color.moveUpPrimary],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    static var moveUpSurfaceGradient: LinearGradient {
        LinearGradient(
            colors: [Color.moveUpSurface, Color.moveUpBackground],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Shadow Extensions
extension View {
    func moveUpShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 2
        )
    }
    
    func moveUpCardShadow() -> some View {
        self.shadow(
            color: Color.black.opacity(0.05),
            radius: 4,
            x: 0,
            y: 1
        )
    }
}
