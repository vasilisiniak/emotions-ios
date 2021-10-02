import Foundation
import UIKit
import Model
import Utils

public enum EmotionsGroupsUseCaseObjects {

    public struct Emotion {

        // MARK: - Fileprivate

        fileprivate init(event: EmotionsGroup.Emotion) {
            name = event.name
            meaning = event.meaning
        }

        // MARK: - Public

        public let name: String
        public let meaning: String
    }
}

public protocol EmotionsGroupsUseCaseOutput: AnyObject {
    func present(clearAvailable: Bool)
    func present(nextAvailable: Bool)
    func present(groups: [String])
    func present(emotions: [EmotionsGroupsUseCaseObjects.Emotion], selected: [String], color: String)
    func present(selectedEmotions: [String], color: String)
    func present(selectedGroupIndex: Int)
    func present(emotionIndex: Int, selected: [String])
    func presentNext(selectedEmotions: [String], color: String)
    func presentFirstLaunch()
    func presentSecondLaunch()
    func presentRate()
    func presentShare(item: UIActivityItemSource)
    func presentShareInfo()
    func presentShareLater()
    func presentNotFound()
}

public protocol EmotionsGroupsUseCase {
    func eventOutputReady()
    func eventClear()
    func eventNext()
    func event(indexChange: Int)
    func eventNextIndex()
    func eventPrevIndex()
    func event(select: String)
    func eventWillShowInfo(emotion: String)
    func eventDidHideInfo()
    func eventShare()
    func eventCancelShare()
    func eventNotFound()
}

public final class EmotionsGroupsUseCaseImpl {

    private enum Constants {
        fileprivate static let FirstLaunchKey = "UseCases.EmotionsGroupsUseCaseImpl.FirstLaunchKey"
        fileprivate static let SecondLaunchKey = "UseCases.EmotionsGroupsUseCaseImpl.SecondLaunchKey"
    }

    // MARK: - Private

    private var firstLaunch: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.FirstLaunchKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.FirstLaunchKey)
            UserDefaults.standard.synchronize()
        }
    }

    private var secondLaunch: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.SecondLaunchKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.SecondLaunchKey)
            UserDefaults.standard.synchronize()
        }
    }

    private let emotionsProvider: EmotionsGroupsProvider
    private let analytics: AnalyticsManager
    private let promoManager: PromoManager
    private let appLink: String
    private var selectedGroupIndex = 0
    private var selectedColor: String!

    private var selectedEmotions: [String] = [] {
        didSet {
            updateSelectedColor()
            output.present(selectedEmotions: selectedEmotions, color: selectedColor)
        }
    }

    private func updateSelectedColor() {
        let counts = emotionsProvider.emotionsGroups.map { $0.emotions.filter { selectedEmotions.contains($0.name) }.count }
        let index = counts.firstIndex { $0 == counts.max() }!
        selectedColor = emotionsProvider.emotionsGroups[index].color
    }

    private func presentEmotionsGroup() {
        let group = emotionsProvider.emotionsGroups[selectedGroupIndex]
        let selected = selectedEmotions.filter { group.emotions.map(\.name).contains($0) }
        output.present(selectedGroupIndex: selectedGroupIndex)
        output.present(emotions: group.emotions.map(EmotionsGroupsUseCaseObjects.Emotion.init), selected: selected, color: group.color)
    }

    private func presentClearNextAvailable() {
        output.present(clearAvailable: selectedEmotions.count > 0)
        output.present(nextAvailable: selectedEmotions.count > 0)
    }

    private func presentFirstLaunch() {
        if !firstLaunch {
            firstLaunch = true
            output.presentFirstLaunch()
        }
        else if !secondLaunch {
            secondLaunch = true
            output.presentSecondLaunch()
        }
    }

    // MARK: - Public

    public weak var output: EmotionsGroupsUseCaseOutput!
    public init(emotionsProvider: EmotionsGroupsProvider, analytics: AnalyticsManager, promoManager: PromoManager, appLink: String) {
        self.emotionsProvider = emotionsProvider
        self.analytics = analytics
        self.promoManager = promoManager
        self.appLink = appLink
    }
}

extension EmotionsGroupsUseCaseImpl: EmotionsGroupsUseCase {
    public func eventShare() {
        let item = LinkActivityItem(title: Bundle.main.appName, url: URL(string: appLink), icon: Bundle.main.appIcon)
        output.presentShare(item: item)
    }

    public func eventCancelShare() {
        output.presentShareLater()
    }

    public func eventWillShowInfo(emotion: String) {
        analytics.track(.emotionDetails(emotion: emotion))
    }

    public func eventDidHideInfo() {
        promoManager.trackActivityEnded(sender: self)
    }

    public func eventNext() {
        output.presentNext(selectedEmotions: selectedEmotions, color: selectedColor)
    }

    public func eventClear() {
        selectedEmotions = []
        output.present(selectedEmotions: selectedEmotions, color: selectedColor)
        presentEmotionsGroup()
        presentClearNextAvailable()
    }

    public func eventOutputReady() {
        output.present(groups: emotionsProvider.emotionsGroups.map(\.name))
        presentEmotionsGroup()
        presentClearNextAvailable()
    }

    public func event(indexChange: Int) {
        selectedGroupIndex = indexChange
        presentEmotionsGroup()
        presentFirstLaunch()
    }

    public func event(select: String) {
        if selectedEmotions.contains(select) {
            selectedEmotions = selectedEmotions.filter { $0 != select }
        }
        else {
            selectedEmotions.append(select)
        }
        let emotions = emotionsProvider.emotionsGroups[selectedGroupIndex].emotions.map(\.name)
        let index = emotions.firstIndex(of: select)!
        output.present(emotionIndex: index, selected: selectedEmotions)
        presentClearNextAvailable()
    }

    public func eventNextIndex() {
        if selectedGroupIndex == (emotionsProvider.emotionsGroups.count - 1) {
            selectedGroupIndex = 0
        }
        else {
            selectedGroupIndex += 1
        }
        presentEmotionsGroup()
        presentFirstLaunch()
    }

    public func eventPrevIndex() {
        if selectedGroupIndex == 0 {
            selectedGroupIndex = emotionsProvider.emotionsGroups.count - 1
        }
        else {
            selectedGroupIndex -= 1
        }
        presentEmotionsGroup()
        presentFirstLaunch()
    }

    public func eventNotFound() {
        analytics.track(.emotionNotFound)
        output.presentNotFound()
    }
}

extension EmotionsGroupsUseCaseImpl: PromoManagerSender {
    public func presentRate() {
        output.presentRate()
    }

    public func presentShare() {
        output.presentShareInfo()
    }
}
