import Foundation
import UIKit
import Model
import Utils

public enum EmotionsGroupsUseCaseObjects {

    public enum Mode {
        case log
        case edit
    }

    public struct Emotion: Equatable {

        // MARK: - Public

        public let name: String
        public let meaning: String
        public let color: String
    }
}

public protocol EmotionsGroupsUseCaseOutput: AnyObject {
    func present(clearAvailable: Bool)
    func present(nextAvailable: Bool)
    func present(groups: [String])
    func present(emotions: [EmotionsGroupsUseCaseObjects.Emotion], selected: [String], color: String, label: Bool)
    func present(selectedEmotions: [String], color: String)
    func present(selectedGroupIndex: Int)
    func presentNext(selectedEmotions: [String], color: String)
    func presentFirstLaunch()
    func presentSecondLaunch()
    func presentRate()
    func presentShare(item: UIActivityItemSource)
    func presentShareInfo()
    func presentShareLater()
    func presentNotFound()
    func present(legacy: Bool)
    func presentCancel()
}

public protocol EmotionsGroupsUseCase {
    var mode: EmotionsGroupsUseCaseObjects.Mode { get }
    func eventOutputReady()
    func eventClear()
    func eventNext()
    func event(indexChange: Int)
    func eventNextIndex()
    func eventPrevIndex()
    func event(select: String)
    func event(search: String?)
    func eventWillShowInfo(emotion: String)
    func eventDidHideInfo()
    func eventShare()
    func eventCancelShare()
    func eventNotFound()
}

public final class EmotionsGroupsUseCaseImpl {

    private enum Constants {
        static let FirstLaunchKey = "UseCases.EmotionsGroupsUseCaseImpl.FirstLaunchKey"
        static let SecondLaunchKey = "UseCases.EmotionsGroupsUseCaseImpl.SecondLaunchKey"
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
    private let settings: Settings
    private let state: StateManager
    private let appLink: String
    private var selectedGroupIndex = 0
    private var selectedColor: String!
    private var token: AnyObject!
    private var search: String?
    private let originalEmotions: [String]?
    public let mode: EmotionsGroupsUseCaseObjects.Mode

    private var selectedEmotions: [String] = [] {
        didSet {
            updateSelectedColor()

            switch mode {
            case .log: state.emotionsGroupsState = selectedEmotions.isEmpty ? nil : (emotions: selectedEmotions, color: selectedColor)
            case .edit: break
            }

            output.present(selectedEmotions: selectedEmotions, color: selectedColor)
        }
    }

    private func updateSelectedColor() {
        let counts = emotionsProvider.emotionsGroups.map { $0.emotions.filter { selectedEmotions.contains($0.name) }.count }
        let index = counts.firstIndex { $0 == counts.max() }!
        selectedColor = emotionsProvider.emotionsGroups[index].color
    }

    private func presentEmotionsGroup() {
        if let search = search {
            let color = "ffffff"

            let names = emotionsProvider.emotionsGroups
                .flatMap { group in group.emotions.map { EmotionsGroupsUseCaseObjects.Emotion(name: $0.name, meaning: $0.meaning, color: group.color) } }
                .filter { search.isEmpty || ($0.name.lowercased().range(of: search.lowercased()) != nil) }
                .sorted { $0.name < $1.name }

            let meanings = emotionsProvider.emotionsGroups
                .flatMap { group in group.emotions.map { EmotionsGroupsUseCaseObjects.Emotion(name: $0.name, meaning: $0.meaning, color: group.color) } }
                .filter { search.isEmpty || ($0.meaning.lowercased().range(of: search.lowercased()) != nil) }
                .filter { !names.contains($0) }
                .sorted { $0.name < $1.name }

            output.present(emotions: (names + meanings), selected: selectedEmotions, color: color, label: settings.reduceAnimation)
        }
        else {
            let group = emotionsProvider.emotionsGroups[selectedGroupIndex]

            let emotions: [EmotionsGroupsUseCaseObjects.Emotion]
            let selectedNames: [String]

            if settings.reduceAnimation {
                emotions = group.emotions.map { EmotionsGroupsUseCaseObjects.Emotion(name: $0.name, meaning: $0.meaning, color: group.color) }
                selectedNames = selectedEmotions.filter { group.emotions.map(\.name).contains($0) }
            }
            else {
                let selected = emotionsProvider.emotionsGroups
                    .flatMap { group in group.emotions.map { EmotionsGroupsUseCaseObjects.Emotion(name: $0.name, meaning: $0.meaning, color: group.color) } }
                    .filter { selectedEmotions.contains($0.name) }

                let filtered = emotionsProvider.emotionsGroups[selectedGroupIndex].emotions
                    .filter { !selectedEmotions.contains($0.name) }
                    .map { EmotionsGroupsUseCaseObjects.Emotion(name: $0.name, meaning: $0.meaning, color: group.color) }

                emotions = selected + filtered
                selectedNames = selectedEmotions
            }

            output.present(selectedGroupIndex: selectedGroupIndex)
            output.present(emotions: emotions, selected: selectedNames, color: group.color, label: settings.reduceAnimation)
        }
    }

    private func presentClearNextAvailable() {
        switch mode {
        case .log:
            output.present(clearAvailable: !selectedEmotions.isEmpty)
            output.present(nextAvailable: !selectedEmotions.isEmpty)
        case .edit:
            output.present(clearAvailable: true)
            output.present(nextAvailable: (originalEmotions != selectedEmotions) && !selectedEmotions.isEmpty)
        }
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

    public init(
        emotionsProvider: EmotionsGroupsProvider,
        analytics: AnalyticsManager,
        promoManager: PromoManager,
        settings: Settings,
        state: StateManager,
        appLink: String,
        emotions: [String]
    ) {
        self.emotionsProvider = emotionsProvider
        self.analytics = analytics
        self.promoManager = promoManager
        self.settings = settings
        self.state = state
        self.appLink = appLink

        originalEmotions = emotions
        mode = emotions.isEmpty ? .log : .edit

        token = self.settings.add { [weak self] in
            self?.output.present(legacy: $0.useLegacyLayout)
            self?.presentEmotionsGroup()
        }

        switch mode {
        case .log:
            if let state = state.emotionsGroupsState {
                selectedEmotions = state.emotions
                selectedColor = state.color
            }
        case .edit:
            selectedEmotions = emotions
            updateSelectedColor()
        }
    }
}

extension EmotionsGroupsUseCaseImpl: EmotionsGroupsUseCase {
    public func eventShare() {
        analytics.track(.acceptRequestShare)
        let item = LinkActivityItem(title: Bundle.main.appName, url: URL(string: appLink), icon: Bundle.main.appIcon)
        output.presentShare(item: item)
    }

    public func eventCancelShare() {
        analytics.track(.declineRequestShare)
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
        switch mode {
        case .log:
            selectedEmotions = []
            presentEmotionsGroup()
            presentClearNextAvailable()
        case .edit:
            output.presentCancel()
        }
    }

    public func eventOutputReady() {
        output.present(legacy: settings.useLegacyLayout)
        output.present(groups: emotionsProvider.emotionsGroups.map(\.name))
        presentEmotionsGroup()
        presentClearNextAvailable()

        if state.emotionNameState?.name != nil || state.emotionNameState?.details != nil || state.emotionNameState?.date != nil {
            output.presentNext(selectedEmotions: selectedEmotions, color: selectedColor)
        }
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
        presentEmotionsGroup()
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

    public func event(search: String?) {
        self.search = search
        presentEmotionsGroup()
    }
}

extension EmotionsGroupsUseCaseImpl: PromoManagerSender {
    public func presentRate() {
        analytics.track(.requestRate)
        output.presentRate()
    }

    public func presentShare() {
        analytics.track(.requestShare)
        output.presentShareInfo()
    }
}
