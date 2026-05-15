import SwiftUI

enum AppTheme {
    static let background = Color(red: 1.0, green: 0.97, blue: 0.88)
    static let surface = Color.white.opacity(0.84)
    static let surfaceStrong = Color(red: 1.0, green: 0.92, blue: 0.63).opacity(0.72)
    static let brandCoral = Color(red: 0.97, green: 0.57, blue: 0.20)
    static let brandMint = Color(red: 0.47, green: 0.63, blue: 0.24)
    static let brandSand = Color(red: 0.98, green: 0.73, blue: 0.07)
    static let brandYellow = Color(red: 0.98, green: 0.73, blue: 0.07)
    static let textPrimary = Color(red: 0.08, green: 0.08, blue: 0.09)
    static let textSecondary = Color.black.opacity(0.62)
    static let heroText = Color.white
    static let heroTextSecondary = Color.white.opacity(0.86)
    static let courtSurfaceTop = Color(red: 0.92, green: 0.82, blue: 0.58)
    static let courtSurfaceBottom = Color(red: 0.82, green: 0.70, blue: 0.43)
    static let courtLine = Color.white.opacity(0.92)
    static let courtBoundary = Color(red: 0.34, green: 0.23, blue: 0.08).opacity(0.28)
    static let courtBadgeBackground = Color.black.opacity(0.52)
    static let courtText = Color(red: 0.17, green: 0.12, blue: 0.05)

    static let heroGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.98),
            brandYellow.opacity(0.34),
            brandCoral.opacity(0.18)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.98, blue: 0.92),
            Color(red: 1.0, green: 0.91, blue: 0.58),
            Color(red: 0.99, green: 0.82, blue: 0.24),
            Color(red: 1.0, green: 0.96, blue: 0.86)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct AppCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)
            .clipped()
    }
}

extension View {
    func appCard() -> some View {
        modifier(AppCardModifier())
    }
}
