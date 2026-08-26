import SwiftUI

// MARK: - ExpandableToggleRow

/// A reusable row component: [icon] Title ---- Toggle
/// When the toggle is ON, an expandable area appears below containing
/// any custom content the caller provides via @ViewBuilder.
struct AlarmSetupExpandableToggle<Content: View>: View {

    // MARK: Public config (customizable by the developer using this component)

    /// SF Symbol name for the leading icon. Pass `nil` to hide the icon.
    var icon: String?

    /// Title text shown next to the icon.
    var title: String

    /// Controls the toggle state. Owned by the parent (source of truth),
    /// so this component stays fully controlled/reusable.
    @Binding var isOn: Bool

    /// Animation used when expanding/collapsing. Customizable, with a sane default.
    var animation: Animation = .easeInOut(duration: 0.25)

    /// Arbitrary content shown in the expanded area when `isOn == true`.
    /// Because this is `@ViewBuilder`, the caller can put literally anything here:
    /// a Form, a VStack of Toggles, a Picker, a custom view, etc.
    @ViewBuilder var content: () -> Content

    // MARK: Init

    init(
        icon: String? = nil,
        title: String,
        isOn: Binding<Bool>,
        animation: Animation = .easeInOut(duration: 0.25),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.icon = icon
        self.title = title
        self._isOn = isOn
        self.animation = animation
        self.content = content
    }

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // --- Header row: icon + title ---- toggle ---
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(.secondary)
                        .frame(width: 22)
                }

                Text(title)
                    .font(.body)

                Spacer()

                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)

            // --- Expanded area, only rendered when toggle is ON ---
            if isOn {
                content()
                    .padding(.top, 4)
                    .transition(
                        .opacity.combined(with: .move(edge: .top))
                    )
            }
        }
        .animation(animation, value: isOn)
    }
}

// MARK: - Example usage

private struct ExampleUsageView: View {
    @State private var notificationsOn = true
    @State private var soundOn = true
    @State private var badgeOn = false

    @State private var locationOn = false

    var body: some View {
        Form {
            Section {
                // Example 1: expanded content = a small settings group
                AlarmSetupExpandableToggle(
                    icon: "bell.fill",
                    title: "Notifications",
                    isOn: $notificationsOn
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Sound", isOn: $soundOn)
                        Toggle("Badge", isOn: $badgeOn)
                    }
                    .padding(.leading, 30)  // indent to align under title
                }

                // Example 2: expanded content = completely different view,
                // proving the component is generic/reusable
                AlarmSetupExpandableToggle(
                    icon: "location.fill",
                    title: "Location Access",
                    isOn: $locationOn
                ) {
                    Text(
                        "Your location will only be used while the app is active."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 30)
                }

                // Example 3: no icon at all (icon param is optional)
                AlarmSetupExpandableToggle(
                    title: "Advanced Mode",
                    isOn: .constant(false)
                ) {
                    Text("Hidden unless toggled on")
                }
            }
        }
    }
}

#Preview {
    ExampleUsageView()
}
