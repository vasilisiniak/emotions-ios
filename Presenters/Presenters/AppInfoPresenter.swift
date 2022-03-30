import Foundation
import MessageUI
import UseCases

public enum AppInfoPresenterObjects {

    public enum Section: Equatable {

        public enum Row: Equatable {

            case securitySettings
            case appearanceSettings
            case rateApp
            case shareApp
            case suggestImprove
            case reportProblem
            case sourceCode
            case designer
            case donate

            public var title: String {
                switch self {
                case .securitySettings: return "Настройки приватности"
                case .appearanceSettings: return "Внешний вид и поведение"
                case .rateApp: return "Оценить приложение"
                case .shareApp: return "Поделиться приложением"
                case .suggestImprove: return "Предложить улучшение"
                case .reportProblem: return "Сообщить о проблеме"
                case .sourceCode: return "Исходный код приложения"
                case .designer: return "Сергей Грабинский"
                case .donate: return "Поддержать разработчика"
                }
            }
        }

        case settings
        case appStore
        case feedback
        case sourceCode
        case design
        case donate

        public var rows: [Row] {
            switch self {
            case .settings: return [.securitySettings, .appearanceSettings]
            case .appStore: return [.rateApp, .shareApp]
            case .feedback: return [.suggestImprove, .reportProblem]
            case .sourceCode: return [.sourceCode]
            case .design: return [.designer]
            case .donate: return [.donate]
            }
        }

        public var title: String {
            switch self {
            case .settings: return "Настройки"
            case .appStore: return "App Store"
            case .feedback: return "Обратная связь"
            case .sourceCode: return "Авторы"
            case .design: return ""
            case .donate: return ""
            }
        }

        public var subtitle: String? {
            switch self {
            case .settings: return nil
            case .appStore: return nil
            case .feedback: return nil
            case .sourceCode: return nil
            case .design: return "Советы и идеи по UI/UX и всякому разному"
            case .donate: return "Для развития этого приложения и создания новых"
            }
        }
    }
}

public protocol AppInfoPresenterOutput: AnyObject {
    func show(sections: [AppInfoPresenterObjects.Section])
    func showEmailAlert(message: String, okButton: String, infoButton: String)
}

public protocol AppInfoRouter: AnyObject {
    func route(emailTheme: String, email: String)
    func route(url: String)
    func route(shareItem: UIActivityItemSource)
}

public protocol AppInfoPresenter {
    func eventViewReady()
    func eventEmailInfo()
    func event(selectIndexPath: IndexPath)
}

public class AppInfoPresenterImpl {

    // MARK: - Private

    private let sections: [AppInfoPresenterObjects.Section] = [
        .settings,
        .appStore,
        .feedback,
        .sourceCode,
        .design,
        .donate
    ]

    private func route(emailTheme: String, email: String) {
        guard MFMailComposeViewController.canSendMail() else {
            output.showEmailAlert(
                message: "Для связи с разработчиком нужно добавить почтовый аккаунт в приложение «Почта»",
                okButton: "OK",
                infoButton: "Как это сделать"
            )
            return
        }
        router.route(emailTheme: emailTheme, email: email)
    }

    // MARK: - Public

    public weak var output: AppInfoPresenterOutput!
    public var useCase: AppInfoUseCase!
    public weak var router: AppInfoRouter!

    public init() {}
}

extension AppInfoPresenterImpl: AppInfoPresenter {
    public func eventViewReady() {
        output.show(sections: sections)
    }

    public func event(selectIndexPath: IndexPath) {
        switch sections[selectIndexPath.section].rows[selectIndexPath.row] {
        case .securitySettings: useCase.event(.securitySettings)
        case .appearanceSettings: useCase.event(.appearanceSettings)
        case .rateApp: useCase.event(.review)
        case .shareApp: useCase.event(.share)
        case .suggestImprove: useCase.event(.suggest)
        case .reportProblem: useCase.event(.report)
        case .sourceCode: useCase.event(.sourceCode)
        case .designer: useCase.event(.designer)
        case .donate: useCase.event(.donate)
        }
    }

    public func eventEmailInfo() {
        useCase.event(.emailInfo)
    }
}

extension AppInfoPresenterImpl: AppInfoUseCaseOutput {
    public func present(emailTheme: String, email: String) {
        route(emailTheme: emailTheme, email: email)
    }

    public func present(url: String) {
        router.route(url: url)
    }

    public func present(share: UIActivityItemSource) {
        router.route(shareItem: share)
    }
}
