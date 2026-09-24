import Foundation

/// A user-facing string in the interface language. Every string that reaches
/// the screen as a plain `String` (display names, messages, anything passed
/// to a component's `String` parameter, anything built with interpolation)
/// goes through this; `Text("…")` literals are localized by SwiftUI already.
/// Literals passed here are extracted into Localizable.xcstrings because the
/// parameter is a `LocalizedStringResource`.
///
/// Write whole sentences with their numbers inside: `L("\(count) designs")`,
/// never `"\(count) " + L("designs")`.
nonisolated func L(_ resource: LocalizedStringResource) -> String {
    String(localized: resource)
}
