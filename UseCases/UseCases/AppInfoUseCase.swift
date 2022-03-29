import Foundation
import UIKit
import Utils
import Model

public enum AppInfoUseCaseObjects {

    public enum ShareEvent {
        case suggest
        case report
        case designer
        case review
        case share
        case sourceCode
        case emailInfo
        case faceIdInfo
        case donate
    }
}

public protocol AppInfoUseCaseOutput: AnyObject {
    func present(emailTheme: String, email: String)
    func present(url: String)
    func present(share: UIActivityItemSource)
    func present(protect: Bool, faceId: Bool, legacy: Bool, compact: Bool, reduceAnimation: Bool, legacyDiary: Bool)
    func presentFaceIdError()
}

public protocol AppInfoUseCase {
    func event(_ event: AppInfoUseCaseObjects.ShareEvent)
    func event(protect: Bool, info: String)
    func event(faceId: Bool, info: String)
    func event(legacy: Bool)
    func event(compact: Bool)
    func event(reduceAnimation: Bool)
    func event(legacyDiary: Bool)
    func eventViewReady()
}

public final class AppInfoUseCaseImpl {

    // MARK: - Private

    private let settings: Settings
    private let analytics: AnalyticsManager
    private let lock: LockManager
    private let appLink: String
    private let email: String
    private let github: String
    private let designer: String
    private let emailInfo: String
    private let faceIdInfo: String
    private let emailTheme: String

    private func share() {
        let item = LinkActivityItem(title: Bundle.main.appName, url: URL(string: appLink), icon: Bundle.main.appIcon)
        output.present(share: item)
    }

    private func evaluate(info: String, operation: @escaping () -> ()) {
        lock.evaluate(info: info) { [weak self] available, passed in
            DispatchQueue.main.async {
                if !available {
                    self?.output.presentFaceIdError()
                }
                if passed {
                    operation()
                }
                self?.presentSettings()
            }
        }
    }

    private func presentSettings() {
        output.present(
            protect: settings.protectSensitiveData,
            faceId: settings.useFaceId,
            legacy: settings.useLegacyLayout,
            compact: !settings.useExpandedDiary,
            reduceAnimation: settings.reduceAnimation,
            legacyDiary: settings.useLegacyDiary
        )
    }

    // MARK: - Public

    public weak var output: AppInfoUseCaseOutput!

    public init(
        settings: Settings,
        analytics: AnalyticsManager,
        lock: LockManager,
        appLink: String,
        email: String,
        github: String,
        designer: String,
        emailInfo: String,
        faceIdInfo: String,
        emailTheme: String
    ) {
        self.settings = settings
        self.analytics = analytics
        self.lock = lock
        self.appLink = appLink
        self.email = email
        self.github = github
        self.designer = designer
        self.emailInfo = emailInfo
        self.faceIdInfo = faceIdInfo
        self.emailTheme = emailTheme
    }
}

extension AppInfoUseCaseImpl: AppInfoUseCase {
    public func event(protect: Bool, info: String) {
        if !protect && settings.useFaceId {
            evaluate(info: info) { [settings] in
                settings.protectSensitiveData = false
                settings.useFaceId = false
            }
        } else {
            settings.protectSensitiveData = protect
            presentSettings()
        }
    }

    public func event(faceId: Bool, info: String) {
        evaluate(info: info) { [settings] in
            settings.protectSensitiveData = true
            settings.useFaceId = faceId
        }
    }

    public func event(legacy: Bool) {
        settings.useLegacyLayout = legacy
    }

    public func event(compact: Bool) {
        settings.useExpandedDiary = !compact
    }

    public func event(reduceAnimation: Bool) {
        settings.reduceAnimation = reduceAnimation
    }

    public func event(legacyDiary: Bool) {
        settings.useLegacyDiary = legacyDiary
    }

    public func eventViewReady() {
        presentSettings()
    }

    public func event(_ event: AppInfoUseCaseObjects.ShareEvent) {
        switch event {
        case .suggest:
            analytics.track(.suggestImprove)
            output.present(emailTheme: "\(emailTheme)[Suggest]", email: email)
        case .report:
            analytics.track(.report)
            output.present(emailTheme: "\(emailTheme)[Report]", email: email)
        case .designer:
            analytics.track(.designer)
            UIApplication.shared.open(URL(string: designer)!)
        case .review:
            analytics.track(.rate)
            output.present(url: "\(appLink)?action=write-review")
        case .share:
            analytics.track(.share)
            share()
        case .sourceCode:
            analytics.track(.sourceCode)
            UIApplication.shared.open(URL(string: github)!)
        case .emailInfo:
            output.present(url: emailInfo)
        case .faceIdInfo:
            output.present(url: faceIdInfo)
        case .donate:
            analytics.track(.donate)
            UIApplication.shared.open(URL(string: "\(github)/blob/release/readme.md")!)
        }
    }
}
