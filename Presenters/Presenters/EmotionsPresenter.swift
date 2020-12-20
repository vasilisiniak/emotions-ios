import UIKit
import UseCases

public protocol EmotionsPresenterOutput: class {
    func showEmotions()
}

public protocol EmotionsPresenter {
    func eventViewReady()
}

public final class EmotionsPresenterImpl {
    
    // MARK: - Public
    
    public weak var output: EmotionsPresenterOutput!
    public var useCase: EmotionsUseCase!
    
    public init() {}
}

extension EmotionsPresenterImpl: EmotionsPresenter {
    public func eventViewReady() {
        useCase.eventOutputReady()
    }
}

extension EmotionsPresenterImpl: EmotionsUseCaseOutput {
    public func presentEmotions() {
        output.showEmotions()
    }
}
