import SwiftUI
import UIKit

/// Nucleus pages hide the navigation bar for their own glass back button, which also switches off
/// UIKit's edge-swipe back. This turns it back on for every navigation stack in the app.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer === interactivePopGestureRecognizer ? viewControllers.count > 1 : true
    }
}

/// A menu label whose icon is red along with its title. iOS tints only the text of
/// destructive menu items, so the image carries its own color.
public struct DestructiveLabel: View {
    let title: LocalizedStringKey
    let systemImage: String

    public init(_ title: LocalizedStringKey, systemImage: String) {
        self.title = title
        self.systemImage = systemImage
    }

    public var body: some View {
        Label {
            Text(title)
        } icon: {
            if let image = UIImage(systemName: systemImage)?.withTintColor(.systemRed, renderingMode: .alwaysOriginal) {
                Image(uiImage: image)
            } else {
                Image(systemName: systemImage)
            }
        }
    }
}

public extension View {
    /// A horizontal swipe that still fires over scroll views; prefer this to `HorizontalSwipe` directly.
    func onHorizontalSwipe(_ direction: UISwipeGestureRecognizer.Direction, perform action: @escaping () -> Void) -> some View {
        modifier(HorizontalSwipeModifier(direction: direction, action: action))
    }
}

private struct HorizontalSwipeModifier: ViewModifier {
    let direction: UISwipeGestureRecognizer.Direction
    let action: () -> Void

    func body(content: Content) -> some View {
        if #available(iOS 18, *) {
            content.gesture(HorizontalSwipe(direction, action: action))
        } else {
            // iOS 17 can't host UIKit recognizers in SwiftUI; a simultaneous drag is close enough.
            content.simultaneousGesture(DragGesture(minimumDistance: 30).onEnded { value in
                let dx = value.translation.width
                guard abs(dx) > abs(value.translation.height) * 1.5, abs(dx) > 60 else { return }
                if (direction == .left && dx < 0) || (direction == .right && dx > 0) { action() }
            })
        }
    }
}

/// A horizontal swipe that fires alongside scroll views. A SwiftUI `DragGesture` over a
/// `ScrollView` gets cancelled by the scroll view's pan, so this goes through UIKit.
@available(iOS 18, *)
public struct HorizontalSwipe: UIGestureRecognizerRepresentable {
    let direction: UISwipeGestureRecognizer.Direction
    let action: () -> Void

    public init(_ direction: UISwipeGestureRecognizer.Direction, action: @escaping () -> Void) {
        self.direction = direction
        self.action = action
    }

    public func makeUIGestureRecognizer(context: Context) -> UISwipeGestureRecognizer {
        let recognizer = UISwipeGestureRecognizer()
        recognizer.direction = direction
        recognizer.delegate = context.coordinator
        return recognizer
    }

    public func handleUIGestureRecognizerAction(_ recognizer: UISwipeGestureRecognizer, context: Context) {
        if recognizer.state == .ended { action() }
    }

    public func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator { Coordinator() }

    public final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
            true
        }

        /// A swipe on a row's swipe actions or along a sideways-scrolling strip belongs to them,
        /// not to the page; only when they don't take it does the page switch.
        public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf other: UIGestureRecognizer) -> Bool {
            if String(describing: type(of: other)).contains("SwipeAction") { return true }
            if let scroll = other.view as? UIScrollView, other === scroll.panGestureRecognizer {
                return scroll.contentSize.width > scroll.bounds.width + 1
            }
            return false
        }
    }
}
