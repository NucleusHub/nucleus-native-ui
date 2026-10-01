import SwiftUI

/// The sliding-pill segment control (WatchlistNav / SegmentPill).
public struct NucleusSegmented<Value: Hashable>: View {
    @Binding var selection: Value
    let items: [(value: Value, title: LocalizedStringKey)]
    let fill: Bool
    @Namespace private var pill

    public init(selection: Binding<Value>, items: [(value: Value, title: LocalizedStringKey)], fill: Bool = false) {
        self._selection = selection
        self.items = items
        self.fill = fill
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                let active = item.value == selection
                Button {
                    guard !active else { return }
                    Haptics.selection()
                    withAnimation(NucleusMotion.quick) { selection = item.value }
                } label: {
                    Text(item.title)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(active ? Nucleus.primaryText : Nucleus.secondaryText)
                        // Filling a row, the segments share its width; tight padding keeps labels whole.
                        .padding(.horizontal, fill ? 6 : 14)
                        .padding(.vertical, 7)
                        .frame(maxWidth: fill ? .infinity : nil)
                        .background {
                            if active {
                                RoundedRectangle(cornerRadius: NucleusRadius.segmentPill, style: .continuous)
                                    .fill(Color(light: .white, dark: .white.opacity(0.15)))
                                    .shadow(color: .black.opacity(0.08), radius: 1.5, y: 1)
                                    .matchedGeometryEffect(id: "pill", in: pill)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .animation(NucleusMotion.quick, value: selection)
        .padding(4)
        .background(RoundedRectangle(cornerRadius: NucleusRadius.segmentTrack, style: .continuous).fill(Color(light: .black.opacity(0.04), dark: .white.opacity(0.05))))
    }
}

/// A page with the Nucleus wallpaper, a round back button and a large title (layouts/PageShell.vue).
public struct NucleusPage<Content: View, Actions: View>: View {
    let title: LocalizedStringKey?
    let content: Content
    let actions: Actions
    @Environment(\.dismiss) private var dismiss

    public init(_ title: LocalizedStringKey? = nil, @ViewBuilder actions: () -> Actions = { EmptyView() }, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
        self.actions = actions()
    }

    public var body: some View {
        ZStack {
            NucleusBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        GlassCircleButton("chevron.left") { dismiss() }
                            .accessibilityLabel("Back")
                        Spacer()
                        actions
                    }
                    .frame(height: 40)

                    if let title {
                        Text(title)
                            .font(.system(size: 34, weight: .bold))
                            .tracking(-0.6)
                            .foregroundStyle(Nucleus.primaryText)
                            .padding(.horizontal, 4)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                    }
                    content
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// A centered glyph + message for empty lists.
public struct NucleusEmptyState: View {
    let systemImage: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    public init(_ systemImage: String, title: LocalizedStringKey, message: LocalizedStringKey) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 30, weight: .regular))
                .foregroundStyle(Nucleus.accent)
                .frame(width: 68, height: 68)
                .nucleusGlass(in: Circle())
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Nucleus.primaryText)
            Text(message)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Nucleus.secondaryText)
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}
