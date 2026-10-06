import XCTest

/// Walks every screen against realistic demo data and attaches a screenshot
/// of each, per mode. This is the visual review loop, not a behavior test:
/// it never fails on layout, it only records what the UI looks like.
///
/// Run it and export the PNGs with:
///   scripts/screenshot-tour.sh [-m light,dark,locale,ax] [section ...]
///
/// The app side (see knowledge/ios-swift/design-system/review-loop.md in Forgeloom):
///   - `UI_TESTING=1` switches to an in-memory store, stand-ins for every
///     network service, and no onboarding.
///   - `UI_TESTING_SEED_DEMO=1` fills it with the demo seed.
///   - `-appearanceMode light|dark` is read from UserDefaults and applied app-wide.
final class ScreenshotTourUITests: XCTestCase {
    override func setUpWithError() throws {
        // One broken path shouldn't cost every later screenshot.
        continueAfterFailure = true
    }

    @MainActor func testTourLight() throws { tour(appearance: "light") }
    @MainActor func testTourDark() throws { tour(appearance: "dark") }

    /// The tour in the project's second language, to catch untranslated or overflowing text.
    @MainActor func testTourSecondLanguage() throws {
        language = "es" // the project's second language
        tour(appearance: "light")
    }

    /// iOS: the largest accessibility text size, to catch clipping and truncation.
    @MainActor func testTourLargestText() throws {
        extraArguments = ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        mode = "ax"
        tour(appearance: "light")
    }

    private var language = "en"
    private var mode: String?
    private var extraArguments: [String] = []

    /// Labels the tour matches by text, per language. Prefer accessibility
    /// identifiers so this stays short.
    private func text(_ english: String) -> String {
        guard language != "en" else { return english }
        return [
            "Done": "Hecho", "Cancel": "Cancelar",
        ][english] ?? english
    }

    // MARK: - Tour

    /// The sections, in order. One per screen or area; add one with every new
    /// screen and a step for every new state.
    static let sections = ["home", "settings"]

    private var selectedSections: [String] {
        let requested = ProcessInfo.processInfo.environment["TOUR_SECTIONS"]?
            .split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } ?? []
        return requested.isEmpty ? Self.sections : Self.sections.filter(requested.contains)
    }

    @MainActor
    private func tour(appearance: String) {
        for section in selectedSections {
            let app = launch(appearance: appearance)
            switch section {
            case "home": tourHome(app, appearance)
            case "settings": tourSettings(app, appearance)
            default: break
            }
            app.terminate()
        }
    }

    // MARK: - Sections

    @MainActor
    private func tourHome(_ app: XCUIApplication, _ appearance: String) {
        snap(app, "01-home", appearance)
        // Each state worth seeing gets its own step: empty, loading, error,
        // many items, a sheet open, a popover open, a row selected…
    }

    @MainActor
    private func tourSettings(_ app: XCUIApplication, _ appearance: String) {
        // Navigate with clicks/taps on accessibility identifiers. On macOS,
        // never send keystrokes: if the app isn't frontmost they land in
        // another app (in one project they opened Finder windows).
        snap(app, "02-settings", appearance)
    }

    // MARK: - Helpers

    @MainActor
    private func launch(appearance: String, environment: [String: String] = [:]) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["UI_TESTING"] = "1"
        app.launchEnvironment["UI_TESTING_SEED_DEMO"] = "1"
        environment.forEach { app.launchEnvironment[$0.key] = $0.value }
        app.launchArguments += ["-appearanceMode", appearance,
                                "-AppleLanguages", "(\(language))", "-AppleLocale", language] + extraArguments
        app.launch()
        return app
    }

    @MainActor
    private func snap(_ app: XCUIApplication, _ name: String, _ appearance: String) {
        #if os(macOS)
        let shot = app.windows.firstMatch.screenshot()
        #else
        let shot = XCUIScreen.main.screenshot()
        #endif
        let attachment = XCTAttachment(screenshot: shot)
        let suffix = mode ?? (language == "en" ? appearance : language)
        attachment.name = "\(name)-\(suffix)"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
