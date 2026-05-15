import Foundation

public struct AnalyticsSessionStore {
    public let storageKey: String
    public var defaults: UserDefaults

    private var entryStorageKey: String {
        "\(storageKey).entry"
    }

    public init(storageKey: String, defaults: UserDefaults = .standard) {
        self.storageKey = storageKey
        self.defaults = defaults
    }

    public func savedURL() -> URL? {
        guard let value = defaults.string(forKey: storageKey) else { return nil }
        return URL(string: value)
    }

    public func savedURL(forEntryURL entryURL: URL) -> URL? {
        guard defaults.string(forKey: entryStorageKey) == entryURL.absoluteString else {
            clear()
            return nil
        }
        return savedURL()
    }

    public func save(url: URL?) {
        guard let url else { return }
        defaults.set(url.absoluteString, forKey: storageKey)
    }

    public func save(entryURL: URL) {
        defaults.set(entryURL.absoluteString, forKey: entryStorageKey)
    }

    public func clear() {
        defaults.removeObject(forKey: storageKey)
        defaults.removeObject(forKey: entryStorageKey)
    }
}
