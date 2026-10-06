import SwiftUI
#if os(macOS)
import AppKit
#endif

/// Light, dark or system, persisted in UserDefaults under `appearanceMode`
/// (so the screenshot tour can pass `-appearanceMode dark` as a launch argument).
nonisolated enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: L("System")
        case .light: L("Light")
        case .dark: L("Dark")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    #if os(macOS)
    /// On macOS apply this through `NSApp.appearance`, not
    /// `.preferredColorScheme(_:)`: that modifier on the WindowGroup's root
    /// content changes the window's identity and left its toolbar collapsed
    /// into the overflow menu at launch.
    var nsAppearance: NSAppearance? {
        switch self {
        case .system: nil
        case .light: NSAppearance(named: .aqua)
        case .dark: NSAppearance(named: .darkAqua)
        }
    }
    #endif
}

extension View {
    /// Applies the saved appearance. Call it inside the root view's body.
    func appAppearance(_ mode: AppearanceMode) -> some View {
        #if os(macOS)
        onAppear { NSApp.appearance = mode.nsAppearance }
            .onChange(of: mode) { _, new in NSApp.appearance = new.nsAppearance }
        #else
        preferredColorScheme(mode.colorScheme)
        #endif
    }
}
