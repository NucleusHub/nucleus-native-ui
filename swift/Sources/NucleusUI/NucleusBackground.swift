import SwiftUI

/// The Nucleus wallpaper: violet/indigo/blue lights, a clipped orbit, a faint grid and,
/// in dark mode, star dust and a vignette. A port of core/BackgroundBlobs.vue.
public struct NucleusBackground: View {
    @Environment(\.colorScheme) private var scheme

    public init() {}

    public var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let dark = scheme == .dark
            ZStack {
                base(dark: dark)

                light(
                    stops: [(0x8B48F6, 0.26), (0x7C3AED, 0.17), (0x581CBE, 0.08), (0x46169B, 0.028)],
                    size: w * 0.72 * 1.4
                )
                .position(x: -w * 0.08 + w * 0.5, y: -h * 0.22 + w * 0.5)
                .opacity(dark ? 1 : 0.55)

                orbit(width: w * 2.5, height: w * 1.68, rotation: -13, startAngle: 150, dark: dark)
                    .position(x: w * 0.44, y: h * 0.02)

                if dark {
                    Dust(tile: 300, dots: Dust.far).opacity(0.9)
                }

                Grid(spacing: 64, dark: dark)
                    .mask(
                        RadialGradient(
                            colors: [.black, .clear],
                            center: UnitPoint(x: 0.5, y: 0.32),
                            startRadius: 0,
                            endRadius: max(w, h) * 0.62
                        )
                    )

                light(
                    stops: [(0x6E72F4, 0.21), (0x5858D6, 0.13), (0x312E81, 0.07), (0x28266E, 0.024)],
                    size: w * 0.68 * 1.5
                )
                .position(x: w * 1.14 - w * 0.34, y: h * 1.26 - w * 0.34)
                .opacity(dark ? 1 : 0.55)

                light(
                    stops: [(0x4A8DFA, 0.16), (0x3072F0, 0.10), (0x2563EB, 0.04), (0x1E50C8, 0.014)],
                    size: w * 0.42 * 1.6
                )
                .position(x: w * 0.22 + w * 0.21, y: h * 0.46 + w * 0.21)
                .opacity(dark ? 1 : 0.55)

                if dark {
                    Dust(tile: 380, dots: Dust.near)
                    RadialGradient(
                        colors: [.clear, Color(hex: 0x04020A, opacity: 0.58)],
                        center: UnitPoint(x: 0.5, y: 0.4),
                        startRadius: max(w, h) * 0.3,
                        endRadius: max(w, h) * 0.85
                    )
                }
            }
            .frame(width: w, height: h)
            // Drawn in the Nucleus purple and turned as one layer, like the web's --backdrop-shift.
            .hueRotation(.degrees(NucleusTheme.shared.accent.hueShift))
            .clipped()
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func base(dark: Bool) -> some View {
        ZStack {
            LinearGradient(
                stops: dark
                    ? [.init(color: Color(hex: 0x0A0714), location: 0), .init(color: Color(hex: 0x08060F), location: 0.42), .init(color: Color(hex: 0x050309), location: 1)]
                    : [.init(color: Color(hex: 0xF6F5FB), location: 0), .init(color: Color(hex: 0xF4F3FA), location: 0.42), .init(color: Color(hex: 0xECEAF4), location: 1)],
                startPoint: .top,
                endPoint: .bottom
            )
            GeometryReader { geo in
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [dark ? Color(hex: 0x26174A, opacity: 0.82) : Color(hex: 0xA855F7, opacity: 0.10), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.75
                        )
                    )
                    .frame(width: geo.size.width * 2.4, height: geo.size.height * 1.1)
                    .position(x: geo.size.width / 2, y: -geo.size.height * 0.1)
            }
        }
    }

    private func light(stops: [(UInt32, Double)], size: CGFloat) -> some View {
        let locations: [CGFloat] = [0, 0.24, 0.48, 0.68]
        var gradientStops = zip(stops, locations).map { stop, loc in
            Gradient.Stop(color: Color(hex: stop.0, opacity: stop.1), location: loc)
        }
        gradientStops.append(.init(color: .clear, location: 0.85))
        return Circle()
            .fill(RadialGradient(stops: gradientStops, center: .center, startRadius: 0, endRadius: size / 2))
            .frame(width: size, height: size)
    }

    private func orbit(width: CGFloat, height: CGFloat, rotation: Double, startAngle: Double, dark: Bool) -> some View {
        Ellipse()
            .stroke(Color(hex: 0x818CF8, opacity: 0.34), lineWidth: 1)
            .frame(width: width, height: height)
            .mask(
                AngularGradient(
                    stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black.opacity(0.62), location: 44 / 360),
                        .init(color: .clear, location: 126 / 360),
                        .init(color: .clear, location: 236 / 360),
                        .init(color: .black.opacity(0.55), location: 318 / 360),
                        .init(color: .black, location: 1),
                    ],
                    center: .center,
                    angle: .degrees(startAngle - 90)
                )
            )
            .rotationEffect(.degrees(rotation))
            .opacity(dark ? 1 : 0.6)
    }
}

private struct Grid: View {
    let spacing: CGFloat
    let dark: Bool

    var body: some View {
        Canvas { ctx, size in
            var path = Path()
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }
            ctx.stroke(path, with: .color(dark ? .white.opacity(0.032) : Color(hex: 0x181526, opacity: 0.045)), lineWidth: 1)
        }
    }
}

/// Tiled star dust; fixed coordinates (from the CSS) so it never shimmers between renders.
private struct Dust: View {
    let tile: CGFloat
    let dots: [(CGFloat, CGFloat, CGFloat, Double)]

    static let far: [(CGFloat, CGFloat, CGFloat, Double)] = [
        (226, 412, 1.0, 0.24), (104, 513, 1.1, 0.21), (492, 425, 1.2, 0.19), (415, 279, 1.0, 0.24),
        (41, 412, 1.4, 0.14), (94, 275, 1.2, 0.20), (189, 207, 1.2, 0.20), (503, 193, 1.3, 0.16),
        (278, 14, 1.1, 0.21), (297, 113, 1.1, 0.21), (411, 72, 1.0, 0.24), (438, 509, 1.0, 0.26),
        (137, 72, 1.3, 0.16), (378, 370, 1.1, 0.22), (220, 310, 1.2, 0.18), (318, 280, 1.0, 0.24),
        (555, 541, 1.0, 0.25), (344, 508, 1.2, 0.19), (51, 191, 1.1, 0.22), (526, 69, 1.4, 0.14),
        (374, 183, 1.0, 0.26), (535, 308, 1.0, 0.24),
    ].map { ($0.0 * 300 / 560, $0.1 * 300 / 560, $0.2, $0.3) }

    static let near: [(CGFloat, CGFloat, CGFloat, Double)] = [
        (134, 19, 1.8, 0.23), (108, 308, 1.7, 0.25), (296, 7, 1.7, 0.26), (327, 173, 1.6, 0.29),
        (277, 269, 1.6, 0.27), (56, 105, 1.3, 0.38), (13, 337, 1.8, 0.23), (17, 239, 1.6, 0.29),
        (221, 169, 1.8, 0.22), (222, 79, 1.4, 0.33), (211, 346, 1.6, 0.28),
    ]

    var body: some View {
        Canvas { ctx, size in
            let cols = Int(ceil(size.width / tile))
            let rows = Int(ceil(size.height / tile))
            for row in 0...rows {
                for col in 0...cols {
                    let ox = CGFloat(col) * tile
                    let oy = CGFloat(row) * tile
                    for (x, y, r, a) in dots {
                        let rect = CGRect(x: ox + x - r, y: oy + y - r, width: r * 2, height: r * 2)
                        ctx.fill(Path(ellipseIn: rect), with: .color(Color(hex: 0xE2DCFF, opacity: a)))
                    }
                }
            }
        }
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black.opacity(0.55), location: 0.22),
                    .init(color: .black.opacity(0.28), location: 0.5),
                    .init(color: .black.opacity(0.55), location: 0.78),
                    .init(color: .black, location: 1),
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}

#Preview {
    NucleusBackground().preferredColorScheme(.dark)
}
