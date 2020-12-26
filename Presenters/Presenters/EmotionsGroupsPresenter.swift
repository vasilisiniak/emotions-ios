import UIKit
import UseCases
import Utils

public enum EmotionsGroupsPresenterObjects {
    
    public struct Emotion {
        
        // MARK: - Fileprivate
        
        fileprivate init(event: EmotionsGroupsUseCaseObjects.Emotion) {
            name = event.name
            meaning = event.meaning
        }
        
        // MARK: - Public
        
        public let name: String
        public let meaning: String
    }
}

public protocol EmotionsGroupsPresenterOutput: class {
    func show(title: String)
    func show(clearButton: String)
    func show(nextButton: String)
    func show(clearButtonEnabled: Bool)
    func show(nextButtonEnabled: Bool)
    func show(groupNames: [String])
    func show(selectedGroupIndex: Int)
    func show(emotions: [EmotionsGroupsPresenterObjects.Emotion], selectedNames: [String], color: UIColor)
    func show(selectedEmotionsNames: String, color: UIColor)
    func show(emotionIndex: Int, selectedNames: [String])
    func show(message: String, button: String)
}

public protocol EmotionsGroupsRouter: class {
    func routeEventName(selectedEmotions: [String], color: String)
}

public protocol EmotionsGroupsPresenter {
    func eventViewReady()
    func eventSwipeLeft()
    func eventSwipeRight()
    func eventClear()
    func eventNext()
    func event(indexChange: Int)
    func event(select: String)
}

public final class EmotionsGroupsPresenterImpl {
    
    // MARK: - Public
    
    public weak var output: EmotionsGroupsPresenterOutput!
    public weak var router: EmotionsGroupsRouter!
    public var useCase: EmotionsGroupsUseCase!
    
    public init() {}
}

extension EmotionsGroupsPresenterImpl: EmotionsGroupsPresenter {
    public func eventNext() {
        useCase.eventNext()
    }
    
    public func eventClear() {
        useCase.eventClear()
    }
    
    public func eventViewReady() {
        output.show(title: "Выберите эмоции")
        output.show(clearButton: "Очистить")
        output.show(nextButton: "Далее❯")
        useCase.eventOutputReady()
    }
    
    public func event(indexChange: Int) {
        useCase.event(indexChange: indexChange)
    }
    
    public func event(select: String) {
        useCase.event(select: select)
    }
    
    public func eventSwipeLeft() {
        useCase.eventNextIndex()
    }
    
    public func eventSwipeRight() {
        useCase.eventPrevIndex()
    }
}

extension EmotionsGroupsPresenterImpl: EmotionsGroupsUseCaseOutput {
    public func presentFirstLaunch() {
        output.show(message: "Задержите палец на эмоции, чтобы увидеть её описание", button: "OK")
    }
    
    public func present(clearAvailable: Bool) {
        output.show(clearButtonEnabled: clearAvailable)
    }
    
    public func present(nextAvailable: Bool) {
        output.show(nextButtonEnabled: nextAvailable)
    }
    
    public func presentNext(selectedEmotions: [String], color: String) {
        router.routeEventName(selectedEmotions: selectedEmotions, color: color)
    }
    
    public func present(emotionIndex: Int, selected: [String]) {
        output.show(emotionIndex: emotionIndex, selectedNames: selected)
    }
    
    public func present(groups: [String]) {
        output.show(groupNames: groups)
    }
    
    public func present(emotions: [EmotionsGroupsUseCaseObjects.Emotion], selected: [String], color: String) {
        let emotions = emotions.map(EmotionsGroupsPresenterObjects.Emotion.init)
        output.show(emotions: emotions, selectedNames: selected, color: UIColor(hex: color))
    }
    
    public func present(selectedEmotions: [String], color: String) {
        output.show(selectedEmotionsNames: selectedEmotions.joined(separator: ", "), color: UIColor(hex: color))
    }
    
    public func present(selectedGroupIndex: Int) {
        output.show(selectedGroupIndex: selectedGroupIndex)
    }
}
