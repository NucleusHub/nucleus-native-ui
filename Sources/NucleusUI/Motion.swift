import SwiftUI
import UIKit

public enum NucleusMotion {
    /// `--nuc-ease`: cubic-bezier(0.22, 1, 0.36, 1).
    public static let ease = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.5)
    public static let quick = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.3)
    /// `--nuc-step`: the delay between staggered children.
    public static let step: Double = 0.055
}

public extension View {
    /// `nuc-in` / `nuc-stagger`: fade up 12pt on first appearance, delayed by `index` steps.
    func nucleusAppear(_ index: Int = 0) -> some View {
        modifier(AppearModifier(delay: Double(min(index, 15)) * NucleusMotion.step))
    }
}

private struct AppearModifier: ViewModifier {
    let delay: Double
    @State private var shown = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(shown || reduceMotion ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : 12)
            .onAppear {
                guard !shown else { return }
                withAnimation(NucleusMotion.ease.delay(delay)) { shown = true }
            }
    }
}

/// Generators are kept and pre-warmed: a fresh one per tap makes the haptic land late,
/// which reads as the tap itself lagging.
@MainActor
public enum Haptics {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private static let notification = UINotificationFeedbackGenerator()
    private static let selector = UISelectionFeedbackGenerator()

    public static func tap() { fire(light) { light.impactOccurred() } }
    public static func soft() { fire(softImpact) { softImpact.impactOccurred() } }
    public static func success() { fire(notification) { notification.notificationOccurred(.success) } }
    public static func warning() { fire(notification) { notification.notificationOccurred(.warning) } }
    public static func error() { fire(notification) { notification.notificationOccurred(.error) } }
    public static func selection() { fire(selector) { selector.selectionChanged() } }

    /// Call once at launch so the first tap is already warm.
    public static func warmUp() {
        for generator in [light, softImpact, notification, selector] as [UIFeedbackGenerator] { generator.prepare() }
    }

    private static func fire(_ generator: UIFeedbackGenerator, _ body: () -> Void) {
        body()
        generator.prepare()
    }
}

/// The app-wide theme choice; web apps default to dark, so do we.
public enum AppearanceMode: String, CaseIterable, Identifiable, Sendable {
    case system, light, dark

    public var id: String { rawValue }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    public var title: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}
