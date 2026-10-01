import SwiftUI

/// A titled glass group of rows (`set-heading` + `lg-glass set-group` + `set-foot`).
public struct NucleusSection<Content: View>: View {
    let header: LocalizedStringKey?
    let footer: Text?
    let content: Content

    public init(_ header: LocalizedStringKey? = nil, footer: Text? = nil, @ViewBuilder content: () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header {
                Text(header)
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(0.5)
                    .textCase(.uppercase)
                    .foregroundStyle(Nucleus.secondaryText)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            SeparatedRows { content }
            .clipShape(RoundedRectangle(cornerRadius: NucleusRadius.card, style: .continuous))
            .nucleusGlass(cornerRadius: NucleusRadius.card)

            if let footer {
                footer
                    .font(.system(size: 13))
                    .foregroundStyle(Nucleus.secondaryText)
                    .lineSpacing(2)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
            }
        }
        .padding(.bottom, 28)
    }
}

/// Rows with a hairline between each, as in a grouped list.
struct SeparatedRows<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if #available(iOS 18, *) {
            VStack(spacing: 0) {
                Group(subviews: content) { subviews in
                    ForEach(Array(subviews.enumerated()), id: \.element.id) { index, subview in
                        if index > 0 { RowSeparator() }
                        subview
                    }
                }
            }
        } else {
            // iOS 17 has no public way to walk subviews; the variadic view tree is what Group(subviews:) replaced.
            _VariadicView.Tree(SeparatedLayout()) { content }
        }
    }
}

private struct RowSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Nucleus.separator)
            .frame(height: 1)
            .padding(.leading, 16)
    }
}

private struct SeparatedLayout: _VariadicView_MultiViewRoot {
    func body(children: _VariadicView.Children) -> some View {
        VStack(spacing: 0) {
            ForEach(children) { child in
                if child.id != children.first?.id { RowSeparator() }
                child
            }
        }
    }
}

/// A 30pt rounded gradient tile holding a white SF Symbol (`.set-icon`).
public struct IconTile: View {
    let systemImage: String
    let tint: NucleusTint
    let size: CGFloat

    public init(_ systemImage: String, tint: NucleusTint = .indigo, size: CGFloat = 30) {
        self.systemImage = systemImage
        self.tint = tint
        self.size = size
    }

    public var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: size * 0.52, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous).fill(tint.gradient))
            .shadow(color: tint.color.opacity(0.35), radius: 4, y: 2)
    }
}

/// One settings row: optional tile, title/subtitle and a trailing accessory.
public struct NucleusRow<Trailing: View>: View {
    let title: Text
    let subtitle: Text?
    let icon: IconTile?
    let titleColor: Color?
    let trailing: Trailing

    public init(
        _ title: LocalizedStringKey,
        subtitle: Text? = nil,
        icon: IconTile? = nil,
        titleColor: Color? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = Text(title)
        self.subtitle = subtitle
        self.icon = icon
        self.titleColor = titleColor
        self.trailing = trailing()
    }

    public init(
        verbatim title: String,
        subtitle: Text? = nil,
        icon: IconTile? = nil,
        titleColor: Color? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.title = Text(verbatim: title)
        self.subtitle = subtitle
        self.icon = icon
        self.titleColor = titleColor
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: 12) {
            if let icon { icon }
            VStack(alignment: .leading, spacing: 2) {
                title
                    .font(.system(size: 16))
                    .foregroundStyle(titleColor ?? Nucleus.primaryText)
                if let subtitle {
                    subtitle
                        .font(.system(size: 13))
                        .foregroundStyle(Nucleus.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(minHeight: 52)
        .contentShape(Rectangle())
    }
}

/// A tappable row with the `set-row:active` press highlight.
public struct NucleusRowButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Nucleus.well : .clear)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

public struct Chevron: View {
    public init() {}

    public var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color(hex: 0x94A3B8))
    }
}

/// The recessed `.set-input` text field.
public struct NucleusField: View {
    let title: LocalizedStringKey
    @Binding var text: String
    let prompt: String
    let secure: Bool
    let monospaced: Bool
    let keyboard: UIKeyboardType

    public init(
        _ title: LocalizedStringKey,
        text: Binding<String>,
        prompt: String = "",
        secure: Bool = false,
        monospaced: Bool = false,
        keyboard: UIKeyboardType = .default
    ) {
        self.title = title
        self._text = text
        self.prompt = prompt
        self.secure = secure
        self.monospaced = monospaced
        self.keyboard = keyboard
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Nucleus.secondaryText)
            Group {
                if secure {
                    SecureField(prompt, text: $text)
                } else {
                    TextField(prompt, text: $text)
                }
            }
            .font(monospaced ? .system(size: 16, design: .monospaced) : .system(size: 16))
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(RoundedRectangle(cornerRadius: NucleusRadius.field, style: .continuous).fill(Nucleus.well))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
