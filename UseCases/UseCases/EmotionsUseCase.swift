import Model

public enum EmotionsUseCaseObjects {
    public enum News {
        case v_1_7_addedLove
        case v_1_8_addedFaceId
        case v_1_9_emotionsRedesign
        case v_1_10_eventDetails
    }
}

private extension News {
    var useCaseNews: EmotionsUseCaseObjects.News {
        switch self {
        case .v_1_7_addedLove: return .v_1_7_addedLove
        case .v_1_8_addedFaceId: return .v_1_8_addedFaceId
        case .v_1_9_emotionsRedesign: return .v_1_9_emotionsRedesign
        case .v_1_10_eventDetails: return .v_1_10_eventDetails
        }
    }
}

public protocol EmotionsUseCaseOutput: AnyObject {
    func presentEmotions()
    func present(news: [EmotionsUseCaseObjects.News])
}

public protocol EmotionsUseCase {
    func eventOutputReady()
    func eventViewIsShown()
}

public final class EmotionsUseCaseImpl {

    // MARK: - Private

    private let newsManager: NewsManager

    // MARK: - Public

    public weak var output: EmotionsUseCaseOutput!
    public init(newsManager: NewsManager) {
        self.newsManager = newsManager
    }
}

extension EmotionsUseCaseImpl: EmotionsUseCase {
    public func eventOutputReady() {
        output.presentEmotions()
    }

    public func eventViewIsShown() {
        let news = newsManager.news().map { $0.useCaseNews }
        guard news.count > 0 else { return }
        output.present(news: news)
    }
}
