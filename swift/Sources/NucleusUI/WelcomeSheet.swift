import SwiftUI

public struct WelcomePoint: Identifiable {
    public let id = UUID()
    let systemImage: String
    let tint: NucleusTint
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    public init(_ systemImage: String, tint: NucleusTint, title: LocalizedStringKey, message: LocalizedStringKey) {
        self.systemImage = systemImage
        self.tint = tint
        self.title = title
        self.message = message
    }
}

/// First-launch sheet (WelcomeModal.vue): an app-specific hero over a spinning glow, then the pitch.
public struct NucleusWelcome<Hero: View, Footer: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let points: [WelcomePoint]
    let primary: LocalizedStringKey
    let onStart: () -> Void
    let hero: Hero
    let footer: Footer
    @State private var spin = false

    public init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey,
        points: [WelcomePoint],
        primary: LocalizedStringKey,
        onStart: @escaping () -> Void,
        @ViewBuilder hero: () -> Hero,
        @ViewBuilder footer: () -> Footer = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.points = points
        self.primary = primary
        self.onStart = onStart
        self.hero = hero()
        self.footer = footer()
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(AngularGradient(colors: [Color(hex: 0x818CF8), Color(hex: 0xC084FC), Color(hex: 0xF472B6), Color(hex: 0x818CF8)].map(\.accentHue), center: .center))
                        .frame(width: 240, height: 240)
                        .blur(radius: 48)
                        .opacity(0.5)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .animation(.linear(duration: 14).repeatForever(autoreverses: false), value: spin)
                    hero
                }
                .frame(height: 230)
                .onAppear { spin = true }

                Text(title)
                    .font(.system(size: 30, weight: .bold))
                    .tracking(-0.5)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Nucleus.primaryText)
                    .nucleusAppear(0)
                Text(subtitle)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Nucleus.secondaryText)
                    .padding(.top, 8)
                    .padding(.horizontal, 12)
                    .nucleusAppear(1)

                VStack(alignment: .leading, spacing: 18) {
                    ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                        HStack(alignment: .top, spacing: 14) {
                            IconTile(point.systemImage, tint: point.tint, size: 40)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(point.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Nucleus.primaryText)
                                Text(point.message)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Nucleus.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .nucleusAppear(index + 2)
                    }
                }
                .padding(.top, 28)
                .padding(.horizontal, 8)

                VStack(spacing: 14) {
                    Button(primary, action: onStart)
                        .buttonStyle(NucleusPrimaryButtonStyle())
                    footer
                }
                .padding(.top, 32)
                .nucleusAppear(points.count + 2)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background {
            RadialGradient(
                colors: [Color(light: Color(hex: 0x818CF8, opacity: 0.22).accentHue, dark: Color(hex: 0x8B5CF6, opacity: 0.32).accentHue), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()
        }
    }
}
