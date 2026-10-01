import SwiftUI
import UIKit

public extension Color {
    /// `0xRRGGBB` literal, mirroring the hex values in the web apps' CSS.
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    /// A color that resolves differently in light and dark appearance.
    init(light: Color, dark: Color) {
        self.init(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

/// The gradient tiles used behind row icons (`.set-icon` variants). Colors live in tokens/tokens.json.
public enum NucleusTint: String, CaseIterable, Codable, Sendable, Identifiable {
    case indigo, violet, blue, sky, teal, emerald, amber, orange, rose, pink, slate

    public var id: String { rawValue }

    // `colors` comes from the tokens (Tokens.swift).

    public var gradient: LinearGradient {
        LinearGradient(colors: [colors.top, colors.bottom], startPoint: .top, endPoint: .bottom)
    }

    public var color: Color { colors.bottom }
}
