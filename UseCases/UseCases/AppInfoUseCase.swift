import Foundation
import UIKit
import Utils
import Model

public enum AppInfoUseCaseObjects {

    public enum ShareEvent {
        case securitySettings
        case appearanceSettings
        case review
        case share
        case suggest
        case report
        case sourceCode
        case designer
        case donate
        case emailInfo
    }
}

public protocol AppInfoUseCaseOutput: AnyObject {
    func present(emailTheme: String, email: String)
    func present(url: String)
    func present(share: UIActivityItemSource)
    func presentPrivacySettings()
}

public protocol AppInfoUseCase {
    func event(_ event: AppInfoUseCaseObjects.ShareEvent)
}

public final class AppInfoUseCaseImpl {

    // MARK: - Private

    private let analytics: AnalyticsManager
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

    // MARK: - Public

    public weak var output: AppInfoUseCaseOutput!

    public init(
        analytics: AnalyticsManager,
        appLink: String,
        email: String,
        github: String,
        designer: String,
        emailInfo: String,
        faceIdInfo: String,
        emailTheme: String
    ) {
        self.analytics = analytics
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

    public func event(_ event: AppInfoUseCaseObjects.ShareEvent) {
        switch event {
        case .securitySettings:
            output.presentPrivacySettings()
        case .appearanceSettings: break
        case .review:
            analytics.track(.rate)
            output.present(url: "\(appLink)?action=write-review")
        case .share:
            analytics.track(.share)
            share()
        case .suggest:
            analytics.track(.suggestImprove)
            output.present(emailTheme: "\(emailTheme)[Suggest]", email: email)
        case .report:
            analytics.track(.report)
            output.present(emailTheme: "\(emailTheme)[Report]", email: email)
        case .sourceCode:
            analytics.track(.sourceCode)
            UIApplication.shared.open(URL(string: github)!)
        case .designer:
            analytics.track(.designer)
            UIApplication.shared.open(URL(string: designer)!)
        case .donate:
            analytics.track(.donate)
            UIApplication.shared.open(URL(string: "\(github)/blob/release/readme.md")!)
        case .emailInfo:
            output.present(url: emailInfo)
        }
    }
}
