import Model
import WidgetKit

public enum EmotionsUseCaseObjects {
    public enum News {
        case v_1_7_addedLove
        case v_1_8_addedFaceId
        case v_1_9_emotionsRedesign
        case v_1_10_eventDetails
        case v_1_11_compactDiary
        case v_1_12_editDate
        case v_1_13_icloud
        case v_1_15_search
        case v_1_16_animation
        case v_1_17_diary
        case v_1_19_appearance
        case v_1_21_trash
        case v_1_22_roadmap
        case v_1_23_notifications
        case v_1_25_percentage
        case v_1_26_saveState
        case v_1_27_editEmotions
        case v_1_28_duplicateEvents
        case v_1_29_colorDiary
        case v_1_30_hotfix
        case v_1_31_widget
    }
}

private extension News {
    var useCaseNews: EmotionsUseCaseObjects.News {
        switch self {
        case .v_1_7_addedLove: return .v_1_7_addedLove
        case .v_1_8_addedFaceId: return .v_1_8_addedFaceId
        case .v_1_9_emotionsRedesign: return .v_1_9_emotionsRedesign
        case .v_1_10_eventDetails: return .v_1_10_eventDetails
        case .v_1_11_compactDiary: return .v_1_11_compactDiary
        case .v_1_12_editDate: return .v_1_12_editDate
        case .v_1_13_icloud: return .v_1_13_icloud
        case .v_1_15_search: return .v_1_15_search
        case .v_1_16_animation: return .v_1_16_animation
        case .v_1_17_diary: return .v_1_17_diary
        case .v_1_19_appearance: return .v_1_19_appearance
        case .v_1_21_trash: return .v_1_21_trash
        case .v_1_22_roadmap: return .v_1_22_roadmap
        case .v_1_23_notifications: return .v_1_23_notifications
        case .v_1_25_percentage: return .v_1_25_percentage
        case .v_1_26_saveState: return .v_1_26_saveState
        case .v_1_27_editEmotions: return .v_1_27_editEmotions
        case .v_1_28_duplicateEvents: return .v_1_28_duplicateEvents
        case .v_1_29_colorDiary: return .v_1_29_colorDiary
        case .v_1_30_hotfix: return .v_1_30_hotfix
        case .v_1_31_widget: return .v_1_31_widget
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
    public init(newsManager: NewsManager, provider: EmotionEventsProvider) {
        self.newsManager = newsManager
        provider.add { WidgetCenter.shared.reloadAllTimelines() }
    }
}

extension EmotionsUseCaseImpl: EmotionsUseCase {
    public func eventOutputReady() {
        output.presentEmotions()
        WidgetCenter.shared.reloadAllTimelines()
    }

    public func eventViewIsShown() {
        let news = newsManager.news().map { $0.useCaseNews }
        guard news.count > 0 else { return }
        output.present(news: news)
    }
}
