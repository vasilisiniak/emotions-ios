import Foundation
import WidgetKit

public protocol NewsManager {
    func news() -> [News]
}

public enum News {
    case v_1_7_addedLove
    case v_1_8_addedFaceId
    case v_1_9_emotionsRedesign
    case v_1_10_eventDetails
}

public final class NewsManagerImpl {

    private enum Constants {
        fileprivate static let VersionKey = "Model.NewsManagerImpl.VersionKey"
    }

    // MARK: - Private

    private let eventsProvider: EmotionEventsProvider

    private var lastNewsVersion: String? {
        get { UserDefaults.standard.string(forKey: Constants.VersionKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: Constants.VersionKey); UserDefaults.standard.synchronize() }
    }

    private let newsList: [String: (version: String, news: [News])] = [
        "1.0": (version: "1.7", news: [.v_1_7_addedLove]),
        "1.7": (version: "1.8", news: [.v_1_8_addedFaceId]),
        "1.8": (version: "1.9", news: [.v_1_9_emotionsRedesign]),
        "1.9": (version: "1.10", news: [.v_1_10_eventDetails]),
    ]

    var isFreshInstall: Bool {
        (lastNewsVersion == nil) && eventsProvider.events.isEmpty
    }

    // MARK: - Public

    public init(eventsProvider: EmotionEventsProvider) {
        self.eventsProvider = eventsProvider
    }
}

extension NewsManagerImpl: NewsManager {
    public func news() -> [News] {
        var news: [News] = []
        let ignoreNews = isFreshInstall
        while true {
            guard let list = newsList[lastNewsVersion ?? "1.0"] else { break }
            news += list.news
            lastNewsVersion = list.version
        }
        return ignoreNews ? [] : news
    }
}
