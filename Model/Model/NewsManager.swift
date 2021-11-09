import Foundation
import WidgetKit

public protocol NewsManager {
    func news() -> [News]
}

public enum News {
    case v_1_7_addedLove
}

public final class NewsManagerImpl {

    private enum Constants {
        fileprivate static let VersionKey = "Model.NewsManagerImpl.VersionKey"
    }

    // MARK: - Private

    private var lastNewsVersion: String? {
        get { UserDefaults.standard.string(forKey: Constants.VersionKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: Constants.VersionKey); UserDefaults.standard.synchronize() }
    }

    private let newsList: [String: (version: String, news: [News])] = [
        "1.0": (version: "1.7", news: [.v_1_7_addedLove])
    ]

    // MARK: - Public

    public init() {}
}

extension NewsManagerImpl: NewsManager {
    public func news() -> [News] {
        var news: [News] = []
        while true {
            guard let list = newsList[lastNewsVersion ?? "1.0"] else { break }
            news += list.news
            lastNewsVersion = list.version
        }
        return news
    }
}
