import Foundation
import WidgetKit

public protocol LogEventUseCaseOutput: class {
    func presentEmotions()
    func presentFirstCreation()
    func presentSecondCreation()
}

public protocol LogEventUseCase {
    func eventOutputReady()
    func eventEventCreated()
}

public final class LogEventUseCaseImpl {
    
    private enum Constants {
        fileprivate static let FirstCreationKey = "UseCases.LogEventUseCaseImpl.FirstCreationKey"
        fileprivate static let SecondCreationKey = "UseCases.LogEventUseCaseImpl.SecondCreationKey"
    }
    
    // MARK: - Private
    
    private var firstCreation: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.FirstCreationKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.FirstCreationKey)
        }
    }
    
    private var secondCreation: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.SecondCreationKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.SecondCreationKey)
        }
    }
    
    // MARK: - Public
    
    public weak var output: LogEventUseCaseOutput!
    public init() {}
}

extension LogEventUseCaseImpl: LogEventUseCase {
    public func eventEventCreated() {
        WidgetCenter.shared.reloadAllTimelines()
        
        if !firstCreation {
            firstCreation = true
            output.presentFirstCreation()
        }
        else if !secondCreation {
            secondCreation = true
            output.presentSecondCreation()
        }
    }
    
    public func eventOutputReady() {
        output.presentEmotions()
    }
}
