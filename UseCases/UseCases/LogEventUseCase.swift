import Foundation
import WidgetKit

public protocol LogEventUseCaseOutput: AnyObject {
    func presentEmotions()
    func presentDairyInfo()
    func presentColorMapInfo()
    func presentWidgetInfo()
    func presentWidgetHelp()
}

public protocol LogEventUseCase {
    func eventOutputReady()
    func eventEventCreated()
    func eventWidgetInfo()
}

public final class LogEventUseCaseImpl {
    
    private enum Constants {
        fileprivate static let FirstCreationKey = "UseCases.LogEventUseCaseImpl.FirstCreationKey"
        fileprivate static let SecondCreationKey = "UseCases.LogEventUseCaseImpl.SecondCreationKey"
        fileprivate static let ThirdCreationKey = "UseCases.LogEventUseCaseImpl.ThirdCreationKey"
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
    
    private var thirdCreation: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.ThirdCreationKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.ThirdCreationKey)
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
            output.presentDairyInfo()
        }
        else if !secondCreation {
            secondCreation = true
            output.presentColorMapInfo()
        }
        else if !thirdCreation {
            thirdCreation = true
            output.presentWidgetInfo()
        }
    }
    
    public func eventOutputReady() {
        output.presentEmotions()
    }
    
    public func eventWidgetInfo() {
        output.presentWidgetHelp()
    }
}
