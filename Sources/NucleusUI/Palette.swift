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

/// Design tokens shared by every Nucleus app (the Tailwind palette the web apps use).
public enum Nucleus {
    /// indigo-600 in light, violet-300 in dark — links, checkmarks, primary glyphs.
    public static let accent = Color(light: Color(hex: 0x4F46E5), dark: Color(hex: 0xC4B5FD))
    public static let primaryText = Color(light: Color(hex: 0x0F172A), dark: .white)
    /// slate-500 / white 45%.
    public static let secondaryText = Color(light: Color(hex: 0x64748B), dark: .white.opacity(0.45))
    /// slate-600 / white 75% — glyphs inside glass circle buttons.
    public static let glyph = Color(light: Color(hex: 0x475569), dark: .white.opacity(0.75))
    public static let separator = Color(light: Color(hex: 0x0F172A, opacity: 0.08), dark: .white.opacity(0.08))
    /// Recessed fill for inputs and segment tracks.
    public static let well = Color(light: Color(hex: 0x0F172A, opacity: 0.05), dark: .white.opacity(0.07))
    public static let danger = Color(light: Color(hex: 0xDC2626), dark: Color(hex: 0xF87171))
    public static let success = Color(light: Color(hex: 0x059669), dark: Color(hex: 0x34D399))
    /// The launch/base color, so nothing flashes between splash and first frame.
    public static let base = Color(light: Color(hex: 0xF4F3FA), dark: Color(hex: 0x08060F))

    public static let primaryGradient = LinearGradient(
        colors: [Color(hex: 0x6366F1), Color(hex: 0x8B5CF6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

/// The gradient tiles used behind row icons (`.set-icon` variants).
public enum NucleusTint: String, CaseIterable, Codable, Sendable, Identifiable {
    case indigo, violet, blue, sky, teal, emerald, amber, orange, rose, pink, slate

    public var id: String { rawValue }

    public var colors: (top: Color, bottom: Color) {
        switch self {
        case .indigo: (Color(hex: 0x818CF8), Color(hex: 0x6366F1))
        case .violet: (Color(hex: 0xA78BFA), Color(hex: 0x8B5CF6))
        case .blue: (Color(hex: 0x60A5FA), Color(hex: 0x3B82F6))
        case .sky: (Color(hex: 0x38BDF8), Color(hex: 0x0EA5E9))
        case .teal: (Color(hex: 0x2DD4BF), Color(hex: 0x14B8A6))
        case .emerald: (Color(hex: 0x34D399), Color(hex: 0x10B981))
        case .amber: (Color(hex: 0xFBBF24), Color(hex: 0xF59E0B))
        case .orange: (Color(hex: 0xFB923C), Color(hex: 0xF97316))
        case .rose: (Color(hex: 0xFB7185), Color(hex: 0xF43F5E))
        case .pink: (Color(hex: 0xF472B6), Color(hex: 0xEC4899))
        case .slate: (Color(hex: 0x94A3B8), Color(hex: 0x64748B))
        }
    }

    public var gradient: LinearGradient {
        LinearGradient(colors: [colors.top, colors.bottom], startPoint: .top, endPoint: .bottom)
    }

    public var color: Color { colors.bottom }
}
