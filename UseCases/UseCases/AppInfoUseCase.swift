import Foundation
import UIKit
import Utils
import Model

public enum AppInfoUseCaseObjects {

    public enum ShareEvent {
        case suggest
        case report
        case designSuggest
        case review
        case share
        case sourceCode
        case emailInfo
        case donate
    }
}

public protocol AppInfoUseCaseOutput: AnyObject {
    func present(emailTheme: String, email: String)
    func present(url: String)
    func present(share: UIActivityItemSource)
    func present(protect: Bool)
}

public protocol AppInfoUseCase {
    func event(_ event: AppInfoUseCaseObjects.ShareEvent)
    func event(protect: Bool)
    func eventViewReady()
}

public final class AppInfoUseCaseImpl {

    // MARK: - Private

    private let settings: Settings
    private let appLink: String
    private let email: String
    private let github: String
    private let emailInfo: String
    private let emailTheme: String

    private func share() {
        let item = LinkActivityItem(title: Bundle.main.appName, url: URL(string: appLink), icon: Bundle.main.appIcon)
        output.present(share: item)
    }

    // MARK: - Public

    public weak var output: AppInfoUseCaseOutput!

    public init(settings: Settings, appLink: String, email: String, github: String, emailInfo: String, emailTheme: String) {
        self.settings = settings
        self.appLink = appLink
        self.email = email
        self.github = github
        self.emailInfo = emailInfo
        self.emailTheme = emailTheme
    }
}

extension AppInfoUseCaseImpl: AppInfoUseCase {
    public func event(protect: Bool) {
        settings.protectSensitiveData = protect
        output.present(protect: settings.protectSensitiveData)
    }

    public func eventViewReady() {
        output.present(protect: settings.protectSensitiveData)
    }

    public func event(_ event: AppInfoUseCaseObjects.ShareEvent) {
        switch event {
        case .suggest: output.present(emailTheme: "\(emailTheme)[Suggest]", email: email)
        case .report: output.present(emailTheme: "\(emailTheme)[Report]", email: email)
        case .designSuggest: output.present(emailTheme: "\(emailTheme)[Design]", email: email)
        case .review: output.present(url: "\(appLink)?action=write-review")
        case .share: share()
        case .sourceCode: output.present(url: github)
        case .emailInfo: output.present(url: emailInfo)
        case .donate: output.present(url: "\(github)/blob/release/readme.md")
        }
    }
}
