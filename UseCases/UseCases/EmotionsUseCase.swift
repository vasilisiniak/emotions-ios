public protocol EmotionsUseCaseOutput: class {
    func presentEmotions()
}

public protocol EmotionsUseCase {
    func eventOutputReady()
}

public final class EmotionsUseCaseImpl {
    
    // MARK: - Public
    
    public weak var output: EmotionsUseCaseOutput!
    public init() {}
}

extension EmotionsUseCaseImpl: EmotionsUseCase {
    public func eventOutputReady() {
        output.presentEmotions()
    }
}
