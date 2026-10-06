// Generated from tokens/tokens.json by scripts/generate_tokens.py. Don't edit by hand.

import SwiftUI

/// Design tokens shared by every Nucleus app.
public enum Nucleus {
    public static let primaryText = Color(light: Color(hex: 0x0F172A), dark: Color(hex: 0xFFFFFF))
    /// slate-500 / white 45%.
    public static let secondaryText = Color(light: Color(hex: 0x64748B), dark: Color(hex: 0xFFFFFF, opacity: 0.45))
    /// slate-600 / white 75%: glyphs inside glass circle buttons.
    public static let glyph = Color(light: Color(hex: 0x475569), dark: Color(hex: 0xFFFFFF, opacity: 0.75))
    public static let separator = Color(light: Color(hex: 0x0F172A, opacity: 0.08), dark: Color(hex: 0xFFFFFF, opacity: 0.08))
    /// Recessed fill for inputs and segment tracks.
    public static let well = Color(light: Color(hex: 0x0F172A, opacity: 0.05), dark: Color(hex: 0xFFFFFF, opacity: 0.07))
    public static let danger = Color(light: Color(hex: 0xDC2626), dark: Color(hex: 0xF87171))
    public static let success = Color(light: Color(hex: 0x059669), dark: Color(hex: 0x34D399))
    /// The launch and base color, so nothing flashes between splash and first frame.
    public static let base = Color(light: Color(hex: 0xF4F3FA), dark: Color(hex: 0x08060F))

    /// Turned to the current accent's hue.
    public static var primaryGradient: LinearGradient { LinearGradient(
        colors: [Color(hex: 0x6366F1).accentHue, Color(hex: 0x8B5CF6).accentHue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    ) }
}

/// Corner radii, in points.
public enum NucleusRadius {
    public static let card: CGFloat = 26
    public static let field: CGFloat = 12
    public static let segmentTrack: CGFloat = 13
    public static let segmentPill: CGFloat = 9
}

public enum NucleusMotion {
    /// `--nuc-ease`: cubic-bezier(0.22, 1, 0.36, 1).
    public static let ease = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.5)
    public static let quick = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.3)
    /// `--nuc-step`: the delay between staggered children.
    public static let step: Double = 0.055
}

public extension NucleusTint {
    /// Top and bottom of the tile gradient.
    var colors: (top: Color, bottom: Color) {
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
}

public extension NucleusAccent {
    static let nucleus = NucleusAccent(id: "nucleus", name: "Nucleus", accent: 0xA855F7, soft: 0xC084FC)
    static let midnight = NucleusAccent(id: "midnight", name: "Midnight", accent: 0x4F6BF6, soft: 0x8FA4FF)
    static let arctic = NucleusAccent(id: "arctic", name: "Arctic", accent: 0x22B8CF, soft: 0x67E3F0)
    static let ember = NucleusAccent(id: "ember", name: "Ember", accent: 0xF2711C, soft: 0xFFA463)
    static let forest = NucleusAccent(id: "forest", name: "Forest", accent: 0x2FA36B, soft: 0x6EE7A8)

    static let presets: [NucleusAccent] = [.nucleus, .midnight, .arctic, .ember, .forest]
}
