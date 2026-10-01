import SwiftUI

/// A modal form: wallpaper, round cancel/confirm buttons flanking a centered title, scrolling content.
public struct NucleusSheetPage<Content: View>: View {
    let title: LocalizedStringKey
    let confirmTitle: LocalizedStringKey?
    let canConfirm: Bool
    let onCancel: () -> Void
    let onConfirm: (() -> Void)?
    let content: Content

    public init(
        _ title: LocalizedStringKey,
        confirmTitle: LocalizedStringKey? = nil,
        canConfirm: Bool = true,
        onCancel: @escaping () -> Void,
        onConfirm: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.confirmTitle = confirmTitle
        self.canConfirm = canConfirm
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .top) {
            NucleusBackground()
            ScrollView {
                VStack(spacing: 0) {
                    content
                }
                .padding(.horizontal, 16)
                .padding(.top, 72)
                .padding(.bottom, 32)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)

            HStack {
                GlassCircleButton("xmark", action: onCancel)
                    .accessibilityLabel("Cancel")
                Spacer()
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Nucleus.primaryText)
                    .lineLimit(1)
                Spacer()
                if let onConfirm {
                    if let confirmTitle {
                        Button(confirmTitle, action: onConfirm)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .frame(height: 40)
                            .background(Capsule().fill(Nucleus.primaryGradient))
                            .opacity(canConfirm ? 1 : 0.4)
                            .disabled(!canConfirm)
                    } else {
                        GlassCircleButton("checkmark", tint: canConfirm ? Nucleus.accent : Nucleus.secondaryText, action: onConfirm)
                            .disabled(!canConfirm)
                            .accessibilityLabel("Save")
                    }
                } else {
                    Color.clear.frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 14)
            .background(alignment: .top) {
                // Scrolled content fades out under the header instead of colliding with the title.
                LinearGradient(
                    stops: [
                        .init(color: Nucleus.base, location: 0),
                        .init(color: Nucleus.base.opacity(0.85), location: 0.55),
                        .init(color: Nucleus.base.opacity(0), location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .top)
            }
        }
    }
}

/// A row of tint swatches for picking an item's color.
public struct TintPicker: View {
    @Binding var selection: NucleusTint

    public init(selection: Binding<NucleusTint>) {
        self._selection = selection
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(NucleusTint.allCases) { tint in
                    Button {
                        Haptics.selection()
                        selection = tint
                    } label: {
                        Circle()
                            .fill(tint.gradient)
                            .frame(width: 30, height: 30)
                            .overlay {
                                if tint == selection {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .heavy))
                                        .foregroundStyle(.white)
                                }
                            }
                            .padding(3)
                            .overlay(Circle().strokeBorder(tint == selection ? tint.color : .clear, lineWidth: 2))
                    }
                    .buttonStyle(NucleusPressStyle())
                    .accessibilityLabel(tint.rawValue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

/// A grid of SF Symbols in tiles, the selected one tinted.
public struct SymbolPicker: View {
    @Binding var selection: String
    let symbols: [String]
    let tint: NucleusTint

    public init(selection: Binding<String>, symbols: [String], tint: NucleusTint) {
        self._selection = selection
        self.symbols = symbols
        self.tint = tint
    }

    public var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), spacing: 10) {
            ForEach(symbols, id: \.self) { symbol in
                Button {
                    Haptics.selection()
                    selection = symbol
                } label: {
                    Image(systemName: symbol)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(symbol == selection ? .white : Nucleus.glyph)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background {
                            RoundedRectangle(cornerRadius: NucleusRadius.field, style: .continuous)
                                .fill(symbol == selection ? AnyShapeStyle(tint.gradient) : AnyShapeStyle(Nucleus.well))
                        }
                }
                .buttonStyle(NucleusPressStyle())
            }
        }
        .padding(16)
    }
}
