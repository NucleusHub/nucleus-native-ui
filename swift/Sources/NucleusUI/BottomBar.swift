import SwiftUI

/// The floating search pill with a round add button beside it (BottomSearch.vue).
public struct NucleusSearchBar: View {
    @Binding var text: String
    var focused: FocusState<Bool>.Binding
    let prompt: LocalizedStringKey
    let onSubmit: () -> Void
    let onAdd: (() -> Void)?

    public init(
        text: Binding<String>,
        focused: FocusState<Bool>.Binding,
        prompt: LocalizedStringKey = "Search",
        onSubmit: @escaping () -> Void = {},
        onAdd: (() -> Void)? = nil
    ) {
        self._text = text
        self.focused = focused
        self.prompt = prompt
        self.onSubmit = onSubmit
        self.onAdd = onAdd
    }

    public var body: some View {
        NucleusGlassContainer(spacing: 8) {
            HStack(spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Nucleus.secondaryText)
                    TextField(prompt, text: $text)
                        .font(.system(size: 16))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.go)
                        .focused(focused)
                        .onSubmit(onSubmit)
                    if !text.isEmpty {
                        Button {
                            text = ""
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .heavy))
                                .foregroundStyle(Nucleus.glyph)
                                .frame(width: 22, height: 22)
                                .background(Circle().fill(Nucleus.well))
                        }
                        .buttonStyle(.plain)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 18)
                .frame(height: 50)
                .contentShape(Capsule())
                .onTapGesture { focused.wrappedValue = true }
                .nucleusGlass(in: Capsule())
                .overlay {
                    if focused.wrappedValue {
                        Capsule().strokeBorder(Nucleus.accent.opacity(0.35), lineWidth: 1.5)
                    }
                }

                if focused.wrappedValue {
                    Button("Cancel") {
                        text = ""
                        focused.wrappedValue = false
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Nucleus.accent)
                    .padding(.horizontal, 18)
                    .frame(height: 50)
                    .nucleusGlass(in: Capsule(), interactive: true)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else if let onAdd {
                    Button {
                        Haptics.tap()
                        onAdd()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Nucleus.accent)
                            .frame(width: 50, height: 50)
                            .contentShape(Circle())
                    }
                    .buttonStyle(NucleusPressStyle())
                    .nucleusGlass(in: Circle(), interactive: true)
                    .accessibilityLabel("Add")
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .animation(NucleusMotion.quick, value: focused.wrappedValue)
        .animation(NucleusMotion.quick, value: text.isEmpty)
        .padding(.horizontal, 16)
        .frame(maxWidth: 560)
    }
}
