import Foundation
import Model

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

public protocol EmotionsGroupsUseCaseOutput: class {
    func present(clearAvailable: Bool)
    func present(nextAvailable: Bool)
    func present(groups: [String])
    func present(emotions: [EmotionsGroupsUseCaseObjects.Emotion], selected: [String], color: String)
    func present(selectedEmotions: [String], color: String)
    func present(selectedGroupIndex: Int)
    func present(emotionIndex: Int, selected: [String])
    func presentNext(selectedEmotions: [String], color: String)
    func presentFirstLaunch()
}

public protocol EmotionsGroupsUseCase {
    func eventOutputReady()
    func eventClear()
    func eventNext()
    func event(indexChange: Int)
    func eventNextIndex()
    func eventPrevIndex()
    func event(select: String)
}

public final class EmotionsGroupsUseCaseImpl {
    
    private enum Constants {
        fileprivate static let FirstLaunchKey = "UseCases.EmotionsGroupsUseCaseImpl.FirstLaunchKey"
    }
    
    // MARK: - Private
    
    private var firstLaunch: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.FirstLaunchKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.FirstLaunchKey)
        }
    }
    
    private let emotionsProvider: EmotionsGroupsProvider
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
        let selected = selectedEmotions.filter { group.emotions.map { $0.name }.contains($0) }
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
    }
    
    // MARK: - Public
    
    public weak var output: EmotionsGroupsUseCaseOutput!
    public init(emotionsProvider: EmotionsGroupsProvider) {
        self.emotionsProvider = emotionsProvider
    }
}

extension EmotionsGroupsUseCaseImpl: EmotionsGroupsUseCase {
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
        output.present(groups: emotionsProvider.emotionsGroups.map { $0.name })
        presentEmotionsGroup()
        presentClearNextAvailable()
    }
    
    public func event(indexChange: Int) {
        self.selectedGroupIndex = indexChange
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
        let emotions = emotionsProvider.emotionsGroups[selectedGroupIndex].emotions.map { $0.name }
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
}
