import Foundation
import WebKit
#if canImport(AVFoundation)
import AVFoundation
#endif

public enum AnalyticsFactory {
    public static func makeConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        #if os(iOS)
        configuration.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        }
        #endif
        if #available(iOS 14.0, macOS 11.0, *) {
            configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            configuration.preferences.javaScriptEnabled = true
        }
        return configuration
    }

    public static func prewarm(url: URL, timeout: TimeInterval = 8) {
        let webView = WKWebView(frame: .zero, configuration: makeConfiguration())
        webView.load(URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeout))
    }

    #if os(iOS) && canImport(AVFoundation)
    @MainActor
    public static func activateAudioSessionIfNeeded() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            #if DEBUG
            print("AnalyticsKit audio session activation failed: \(error.localizedDescription)")
            #endif
        }
    }
    #endif
}
