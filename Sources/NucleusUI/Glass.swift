import SwiftUI

public extension View {
    /// The `lg-glass` surface: native Liquid Glass with the faint violet cast the web apps give it in dark mode.
    func nucleusGlass<S: Shape>(in shape: S, interactive: Bool = false) -> some View {
        modifier(NucleusGlassModifier(shape: shape, interactive: interactive))
    }

    func nucleusGlass(cornerRadius: CGFloat = 26, interactive: Bool = false) -> some View {
        nucleusGlass(in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous), interactive: interactive)
    }
}

private struct NucleusGlassModifier<S: Shape>: ViewModifier {
    let shape: S
    let interactive: Bool
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        let tint = scheme == .dark ? Color(hex: 0x0E0A1C, opacity: 0.35) : Color.white.opacity(0.25)
        content.glassEffect(interactive ? .regular.tint(tint).interactive() : .regular.tint(tint), in: shape)
    }
}

/// The 40pt round glass button used in page headers (back, settings, stats…).
public struct GlassCircleButton: View {
    let systemImage: String
    let size: CGFloat
    let tint: Color?
    let action: () -> Void

    public init(_ systemImage: String, size: CGFloat = 40, tint: Color? = nil, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.size = size
        self.tint = tint
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundStyle(tint ?? Nucleus.glyph)
                .frame(width: size, height: size)
                .contentShape(Circle())
        }
        .buttonStyle(NucleusPressStyle())
        .nucleusGlass(in: Circle(), interactive: true)
    }
}

/// `nuc-press`: a quick scale-down on touch.
public struct NucleusPressStyle: ButtonStyle {
    var scale: CGFloat

    public init(scale: CGFloat = 0.94) {
        self.scale = scale
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

/// Full-width gradient capsule used for the main action of a sheet.
public struct NucleusPrimaryButtonStyle: ButtonStyle {
    var destructive: Bool
    @Environment(\.isEnabled) private var isEnabled

    public init(destructive: Bool = false) {
        self.destructive = destructive
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background {
                Capsule().fill(
                    destructive
                        ? AnyShapeStyle(LinearGradient(colors: [Color(hex: 0xF87171), Color(hex: 0xDC2626)], startPoint: .top, endPoint: .bottom))
                        : AnyShapeStyle(Nucleus.primaryGradient)
                )
            }
            .overlay(Capsule().strokeBorder(.white.opacity(0.28), lineWidth: 1).blendMode(.overlay))
            .shadow(color: (destructive ? Color(hex: 0xDC2626) : Color(hex: 0x4F46E5)).opacity(0.45), radius: 12, y: 6)
            .opacity(isEnabled ? 1 : 0.5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

/// Neutral capsule — the "Cancel" of a two-button sheet footer.
public struct NucleusSecondaryButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Nucleus.primaryText)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(Capsule().fill(Nucleus.well))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}
