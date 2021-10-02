import Foundation
import WidgetKit
import UIKit
import Model
import Utils

public protocol LogEventUseCaseOutput: AnyObject {
    func presentEmotions()
    func presentDairyInfo()
    func presentColorMapInfo()
    func presentWidgetInfo()
    func presentWidgetHelp(link: String)
    func presentRate()
    func presentShare(item: UIActivityItemSource)
    func presentShareInfo()
    func presentShareLater()
}

public protocol LogEventUseCase {
    func eventOutputReady()
    func eventEventCreated()
    func eventWidgetInfo()
    func eventShare()
    func eventCancelShare()
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
            UserDefaults.standard.synchronize()
        }
    }

    private var secondCreation: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.SecondCreationKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.SecondCreationKey)
            UserDefaults.standard.synchronize()
        }
    }

    private var thirdCreation: Bool {
        get {
            UserDefaults.standard.bool(forKey: Constants.ThirdCreationKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.ThirdCreationKey)
            UserDefaults.standard.synchronize()
        }
    }

    private let promoManager: PromoManager
    private let appLink: String

    // MARK: - Public

    public weak var output: LogEventUseCaseOutput!

    public init(promoManager: PromoManager, appLink: String) {
        self.promoManager = promoManager
        self.appLink = appLink
    }
}

extension LogEventUseCaseImpl: LogEventUseCase {
    public func eventShare() {
        let item = LinkActivityItem(title: Bundle.main.appName, url: URL(string: appLink), icon: Bundle.main.appIcon)
        output.presentShare(item: item)
    }

    public func eventCancelShare() {
        output.presentShareLater()
    }

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
        else {
            promoManager.trackActivityEnded(sender: self)
        }
    }

    public func eventOutputReady() {
        output.presentEmotions()
    }

    public func eventWidgetInfo() {
        output.presentWidgetHelp(link: "https://support.apple.com/ru-ru/HT207122")
    }
}

extension LogEventUseCaseImpl: PromoManagerSender {
    public func presentShare() {
        output.presentShareInfo()
    }

    public func presentRate() {
        output.presentRate()
    }
}
