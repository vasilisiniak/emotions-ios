import Foundation
import Model

public protocol EmotionsGroupsUseCaseOutput: class {
    func present(title: String)
    func present(clearButton: String)
    func present(nextButton: String)
    func present(clearButtonEnabled: Bool)
    func present(nextButtonEnabled: Bool)
    func present(groups: [String])
    func present(emotions: [String], selected: [String], color: String)
    func present(selectedEmotions: [String])
    func present(selectedGroupIndex: Int)
    func present(emotionIndex: Int, selected: [String])
    func presentNext(selectedEmotions: [String])
}

public protocol EmotionsGroupsEventsHandler {
    func eventViewReady()
    func eventClear()
    func eventNext()
    func event(indexChange: Int)
    func event(select: String)
    func eventSwipeLeft()
    func eventSwipeRight()
}

public protocol EmotionsGroupsUseCase: EmotionsGroupsEventsHandler {}

public class EmotionsGroupsUseCaseImpl {
    
    // MARK: - Private
    
    private let emotionsProvider: EmotionsGroupsProvider
    private var selectedGroupIndex = 0
    private var selectedEmotions: [String] = []
    
    private func presentEmotionsGroup() {
        let group = emotionsProvider.emotionsGroups[selectedGroupIndex]
        let selected = selectedEmotions.filter { group.emotions.contains($0) }
        output.present(selectedGroupIndex: selectedGroupIndex)
        output.present(emotions: group.emotions, selected: selected, color: group.color)
    }
    
    private func presentClearNextButtonsEnabled() {
        output.present(clearButtonEnabled: selectedEmotions.count > 0)
        output.present(nextButtonEnabled: selectedEmotions.count > 0)
    }
    
    // MARK: - Public
    
    public weak var output: EmotionsGroupsUseCaseOutput!
    public init(emotionsProvider: EmotionsGroupsProvider) {
        self.emotionsProvider = emotionsProvider
    }
}

extension EmotionsGroupsUseCaseImpl: EmotionsGroupsUseCase {}

extension EmotionsGroupsUseCaseImpl: EmotionsGroupsEventsHandler {
    public func eventNext() {
        output.presentNext(selectedEmotions: selectedEmotions)
    }
    
    public func eventClear() {
        selectedEmotions = []
        output.present(selectedEmotions: selectedEmotions)
        presentEmotionsGroup()
        presentClearNextButtonsEnabled()
    }
    
    public func eventViewReady() {
        output.present(title: "Выберите эмоции")
        output.present(clearButton: "Очистить")
        output.present(nextButton: "Далее❯")
        output.present(groups: emotionsProvider.emotionsGroups.map { $0.name })
        presentEmotionsGroup()
        presentClearNextButtonsEnabled()
    }
    
    public func event(indexChange: Int) {
        self.selectedGroupIndex = indexChange
        presentEmotionsGroup()
    }
    
    public func event(select: String) {
        if selectedEmotions.contains(select) {
            selectedEmotions = selectedEmotions.filter { $0 != select }
        }
        else {
            selectedEmotions.append(select)
        }
        let emotions = emotionsProvider.emotionsGroups[selectedGroupIndex].emotions
        let index = emotions.firstIndex(of: select)!
        output.present(selectedEmotions: selectedEmotions)
        output.present(emotionIndex: index, selected: selectedEmotions)
        presentClearNextButtonsEnabled()
    }
    
    public func eventSwipeLeft() {
        if selectedGroupIndex == (emotionsProvider.emotionsGroups.count - 1) {
            selectedGroupIndex = 0
        }
        else {
            selectedGroupIndex += 1
        }
        self.presentEmotionsGroup()
    }
    
    public func eventSwipeRight() {
        if selectedGroupIndex == 0 {
            selectedGroupIndex = emotionsProvider.emotionsGroups.count - 1
        }
        else {
            selectedGroupIndex -= 1
        }
        self.presentEmotionsGroup()
    }
}
