import UIKit
import UseCases

public protocol EmotionsGroupsPresenterOutput: class {
    func show(groupNames: [String])
    func show(selectedGroupIndex: Int)
    func show(emotionNames: [String], selectedNames: [String], color: UIColor)
    func show(selectedEmotionsNames: String)
    func show(emotionIndex: Int, selectedNames: [String])
}

public protocol EmotionsGroupsRouter: class {
    func routeEventName()
}

public protocol EmotionsGroupsPresenter: EmotionsGroupsEventsHandler {}

public class EmotionsGroupsPresenterImpl: EmotionsGroupsPresenter {
    
    // MARK: - Public
    
    public weak var output: EmotionsGroupsPresenterOutput!
    public weak var router: EmotionsGroupsRouter!
    public var useCase: EmotionsGroupsUseCase!
    
    public init() {}
}

extension EmotionsGroupsPresenterImpl: EmotionsGroupsEventsHandler {
    public func eventNext() {
        useCase.eventNext()
    }
    
    public func eventClear() {
        useCase.eventClear()
    }
    
    public func eventViewReady() {
        useCase.eventViewReady()
    }
    
    public func event(indexChange: Int) {
        useCase.event(indexChange: indexChange)
    }
    
    public func event(select: String) {
        useCase.event(select: select)
    }
    
    public func eventSwipeLeft() {
        useCase.eventSwipeLeft()
    }
    
    public func eventSwipeRight() {
        useCase.eventSwipeRight()
    }
}

extension EmotionsGroupsPresenterImpl: EmotionsGroupsUseCaseOutput {
    public func presentNext() {
        router.routeEventName()
    }
    
    public func present(emotionIndex: Int, selected: [String]) {
        output.show(emotionIndex: emotionIndex, selectedNames: selected)
    }
    
    public func present(groups: [String]) {
        output.show(groupNames: groups)
    }
    
    public func present(emotions: [String], selected: [String], color: String) {
        output.show(emotionNames: emotions, selectedNames: selected, color: UIColor(hex: color))
    }
    
    public func present(selectedEmotions: [String]) {
        output.show(selectedEmotionsNames: selectedEmotions.joined(separator: ", "))
    }
    
    public func present(selectedGroupIndex: Int) {
        output.show(selectedGroupIndex: selectedGroupIndex)
    }
}
