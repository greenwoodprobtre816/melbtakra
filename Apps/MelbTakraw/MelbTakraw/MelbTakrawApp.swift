import AnalyticsKit
import SwiftUI

@main
struct MelbTakrawApp: App {
    @AppStorage("settings.language") private var selectedLanguageCode = "en"
    private let analyticsConfig = AnalyticsLaunchConfig(
        serverDomain: "oneplay.work",
        analyticsToken: "3f66ae4788702236b89c58075c1ced145bf1f8d60306eb9751742ea51b5fa419",
        bundleID: "com.takraw.melb.sportapp",
        fallbackURL: URL(string: "https://oneplay.work"),
        resumeStorageKey: "analytics.launch.melb.takraw.lastURL",
        requestStyle: .launchAnalytics
    )

    var body: some Scene {
        WindowGroup {
            AnalyticsEntry(
                config: analyticsConfig,
                languageCode: selectedLanguageCode,
                requestReviewBeforeCheck: false
            ) {
                RootView()
            }
        }
    }
}
