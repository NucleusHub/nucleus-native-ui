import Observation
import SwiftUI
import UIKit

/// One accent from the configurator: the colour itself and the lighter step used on dark ground.
public struct NucleusAccent: Hashable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let accent: UInt32
    public let soft: UInt32

    public init(id: String, name: String, accent: UInt32, soft: UInt32) {
        self.id = id
        self.name = name
        self.accent = accent
        self.soft = soft
    }

    /// A colour the user picked. Like the web, it is its own soft step.
    public static func custom(_ hex: UInt32) -> NucleusAccent {
        NucleusAccent(id: "custom", name: "Custom", accent: hex, soft: hex)
    }

    public var isCustom: Bool { id == "custom" }

    /// The accent in light appearance, the soft step in dark.
    public var color: Color { Color(light: Color(hex: accent), dark: Color(hex: soft)) }

    /// Degrees from the Nucleus purple to this accent, the shorter way round (`--backdrop-shift`).
    public var hueShift: Double {
        let shift = Self.hue(of: accent) - Self.hue(of: NucleusAccent.nucleus.accent)
        return (shift + 540).truncatingRemainder(dividingBy: 360) - 180
    }

    static func hue(of hex: UInt32) -> Double {
        var h: CGFloat = 0
        UIColor(Color(hex: hex)).getHue(&h, saturation: nil, brightness: nil, alpha: nil)
        return Double(h) * 360
    }
}

/// Which accent the app wears. Each app has its own, synced with its data; the account can set one
/// for every app, which wins while it is set. Views that read `Nucleus.accent` or
/// `Nucleus.primaryGradient` redraw when either changes. Both are cached per device, so the
/// right colours are there from the first frame.
@Observable
public final class NucleusTheme: @unchecked Sendable {
    public static let shared = NucleusTheme()

    /// This app's own accent.
    public var app: NucleusAccent { didSet { save(app, as: Self.appKey) } }
    /// The account-wide accent from Nucleus ID, or nil to let each app choose.
    public var account: NucleusAccent? { didSet { save(account, as: Self.accountKey) } }

    /// What is on screen: the account's accent over the app's.
    public var accent: NucleusAccent { account ?? app }

    @ObservationIgnored private let defaults: UserDefaults
    private static let appKey = "nucleus.accent"
    private static let accountKey = "nucleus.accountAccent"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        app = Self.load(Self.appKey, from: defaults) ?? .nucleus
        account = Self.load(Self.accountKey, from: defaults)
    }

    private func save(_ accent: NucleusAccent?, as key: String) {
        defaults.set(accent?.id, forKey: key)
        defaults.set(accent?.customHex, forKey: key + ".custom")
    }

    private static func load(_ key: String, from defaults: UserDefaults) -> NucleusAccent? {
        NucleusAccent(id: defaults.string(forKey: key), customHex: defaults.string(forKey: key + ".custom"))
    }
}

public extension NucleusAccent {
    /// From the stored form shared with the server and the web: a preset id, or `custom` with `#RRGGBB`.
    init?(id: String?, customHex: String?) {
        if id == "custom" {
            guard let hex = customHex.flatMap(Self.parseHex) else { return nil }
            self = .custom(hex)
        } else if let preset = Self.presets.first(where: { $0.id == id }) {
            self = preset
        } else {
            return nil
        }
    }

    /// `#RRGGBB` for a custom accent, nil for a preset.
    var customHex: String? { isCustom ? String(format: "#%06X", accent) : nil }

    private static func parseHex(_ s: String) -> UInt32? {
        let digits = s.hasPrefix("#") ? s.dropFirst() : Substring(s)
        return digits.count == 6 ? UInt32(digits, radix: 16) : nil
    }
}

public extension Nucleus {
    /// The chosen accent: links, checkmarks, primary glyphs, the app tint.
    static var accent: Color { NucleusTheme.shared.accent.color }
}

extension Color {
    /// This colour turned from the Nucleus purple to the current accent's hue.
    var accentHue: Color {
        let shift = NucleusTheme.shared.accent.hueShift
        guard shift != 0 else { return self }
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        let turned = (Double(h) + shift / 360 + 1).truncatingRemainder(dividingBy: 1)
        return Color(hue: turned, saturation: Double(s), brightness: Double(b), opacity: Double(a))
    }

    /// `0xRRGGBB` of this colour in sRGB.
    var hexValue: UInt32 {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: nil)
        func byte(_ c: CGFloat) -> UInt32 { UInt32((min(max(c, 0), 1) * 255).rounded()) }
        return byte(r) << 16 | byte(g) << 8 | byte(b)
    }
}

public extension View {
    /// Tints the view with the chosen accent and keeps it current. Put it on the root view.
    func nucleusAccentTint() -> some View {
        modifier(AccentTintModifier())
    }
}

private struct AccentTintModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.tint(NucleusTheme.shared.accent.color)
    }
}

/// The configurator's accent swatches plus a custom colour well, as one settings row.
/// With `noneTitle`, a first swatch clears the selection (the account's "each app chooses").
public struct NucleusAccentPicker: View {
    private let title: LocalizedStringKey
    private let noneTitle: String?
    @Binding private var selection: NucleusAccent?

    public init(_ title: LocalizedStringKey = "Accent", selection: Binding<NucleusAccent?>, noneTitle: String? = nil) {
        self.title = title
        self.noneTitle = noneTitle
        _selection = selection
    }

    /// Bound to this app's own accent.
    public init(_ title: LocalizedStringKey = "Accent", theme: NucleusTheme = .shared) {
        self.init(title, selection: Binding(get: { theme.app }, set: { if let accent = $0 { theme.app = accent } }))
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                Spacer()
                Text(selection?.name ?? noneTitle ?? "").foregroundStyle(Nucleus.secondaryText)
            }
            .font(.system(size: 16))

            HStack(spacing: 0) {
                if let noneTitle {
                    swatch(selected: selection == nil) {
                        Circle()
                            .fill(AngularGradient(colors: (NucleusAccent.presets + [.nucleus]).map { Color(hex: $0.accent) }, center: .center))
                            .opacity(0.55)
                    }
                    .onTapGesture { pick(nil) }
                    .accessibilityLabel(noneTitle)
                    .accessibilityAddTraits(selection == nil ? [.isButton, .isSelected] : .isButton)
                    Spacer(minLength: 0)
                }
                ForEach(NucleusAccent.presets) { preset in
                    swatch(selected: selection == preset) {
                        Circle().fill(LinearGradient(colors: [Color(hex: preset.soft), Color(hex: preset.accent)],
                                                     startPoint: .top, endPoint: .bottom))
                    }
                    .onTapGesture { pick(preset) }
                    .accessibilityLabel(preset.name)
                    .accessibilityAddTraits(selection == preset ? [.isButton, .isSelected] : .isButton)
                    Spacer(minLength: 0)
                }
                swatch(selected: selection?.isCustom == true) {
                    ColorPicker("Custom", selection: customColor, supportsOpacity: false)
                        .labelsHidden()
                }
            }
        }
        .padding(16)
    }

    private var customColor: Binding<Color> {
        Binding(
            get: { Color(hex: selection?.isCustom == true ? selection!.accent : NucleusAccent.nucleus.accent) },
            set: { pick(.custom($0.hexValue)) }
        )
    }

    private func pick(_ accent: NucleusAccent?) {
        guard accent != selection else { return }
        Haptics.tap()
        withAnimation(NucleusMotion.quick) { selection = accent }
    }

    private func swatch<S: View>(selected: Bool, @ViewBuilder content: () -> S) -> some View {
        content()
            .frame(width: 32, height: 32)
            .padding(4)
            .overlay(Circle().strokeBorder(selected ? Nucleus.primaryText : .clear, lineWidth: 2))
            .contentShape(Circle())
    }
}
