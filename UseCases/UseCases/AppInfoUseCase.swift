import Foundation
import UIKit
import Utils

public enum AppInfoUseCaseObjects {

    public enum ShareEvent {
        case suggest
        case report
        case designSuggest
        case review
        case share
        case sourceCode
        case emailInfo
    }
}

public protocol AppInfoUseCaseOutput: AnyObject {
    func present(emailTheme: String, email: String)
    func present(url: String)
    func present(share: UIActivityItemSource)
}

public protocol AppInfoUseCase {
    func event(_ event: AppInfoUseCaseObjects.ShareEvent)
}

public final class AppInfoUseCaseImpl {

    private enum Constants {
        static let email = "vasili.siniak+emotions@gmail.com"
        static let github = "https://github.com/vasilisiniak/emotions-ios"
        static let emailInfo = "https://support.apple.com/ru-ru/HT201320"
    }

    // MARK: - Private

    private let appLink: String

    private func share() {
        let item = LinkActivityItem(title: Bundle.main.appName, url: URL(string: appLink), icon: Bundle.main.appIcon)
        output.present(share: item)
    }

    // MARK: - Public

    public weak var output: AppInfoUseCaseOutput!

    public init(appLink: String) {
        self.appLink = appLink
    }
}

extension AppInfoUseCaseImpl: AppInfoUseCase {
    public func event(_ event: AppInfoUseCaseObjects.ShareEvent) {
        switch event {
        case .suggest: output.present(emailTheme: "[Emotions][Suggest]", email: Constants.email)
        case .report: output.present(emailTheme: "[Emotions][Report]", email: Constants.email)
        case .designSuggest: output.present(emailTheme: "[Emotions][Design]", email: Constants.email)
        case .review: output.present(url: "\(appLink)?action=write-review")
        case .share: share()
        case .sourceCode: output.present(url: Constants.github)
        case .emailInfo: output.present(url: Constants.emailInfo)
        }
    }
}
