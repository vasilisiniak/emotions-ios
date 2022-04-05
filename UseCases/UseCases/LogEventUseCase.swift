import Foundation
import UIKit
import Model
import Utils

public protocol LogEventUseCaseOutput: AnyObject {
    func presentEmotions()
    func presentDiaryInfo()
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
        static let FirstCreationKey = "UseCases.LogEventUseCaseImpl.FirstCreationKey"
        static let SecondCreationKey = "UseCases.LogEventUseCaseImpl.SecondCreationKey"
        static let ThirdCreationKey = "UseCases.LogEventUseCaseImpl.ThirdCreationKey"
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
    private let analytics: AnalyticsManager
    private let appLink: String

    private func share() {
        analytics.track(.share)
        let item = LinkActivityItem(title: Bundle.main.appName, url: URL(string: appLink), icon: Bundle.main.appIcon)
        output.presentShare(item: item)
    }

    private func rate() {
        analytics.track(.rate)
        output.presentRate()
    }

    // MARK: - Public

    public weak var output: LogEventUseCaseOutput!

    public init(promoManager: PromoManager, analytics: AnalyticsManager, appLink: String) {
        self.promoManager = promoManager
        self.analytics = analytics
        self.appLink = appLink
    }
}

extension LogEventUseCaseImpl: LogEventUseCase {
    public func eventShare() {
        share()
    }

    public func eventCancelShare() {
        output.presentShareLater()
    }

    public func eventEventCreated() {
        if !firstCreation {
            firstCreation = true
            output.presentDiaryInfo()
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
        rate()
    }
}
