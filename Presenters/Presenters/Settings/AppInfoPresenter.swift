import Foundation
import MessageUI
import UseCases

fileprivate extension AppInfoPresenterImpl {

    enum Section: SettingsPresenterSection, Equatable {

        enum Row: SettingsPresenterRow, Equatable {

            case securitySettings
            case appearanceSettings
            case rateApp
            case shareApp
            case suggestImprove
            case reportProblem
            case sourceCode
            case designer
            case donate

            var title: String {
                switch self {
                case .securitySettings: return "Настройки приватности"
                case .appearanceSettings: return "Отображение и поведение"
                case .rateApp: return "Оценить приложение"
                case .shareApp: return "Поделиться приложением"
                case .suggestImprove: return "Предложить улучшение"
                case .reportProblem: return "Сообщить о проблеме"
                case .sourceCode: return "Исходный код приложения"
                case .designer: return "Сергей Грабинский"
                case .donate: return "Поддержать разработчика"
                }
            }

            var style: SettingsPresenterRowStyle { .disclosure }
            var value: Any? { nil }
        }

        case settings
        case appStore
        case feedback
        case sourceCode
        case design
        case donate

        var rows: [SettingsPresenterRow] { sectionRows }

        var sectionRows: [Row] {
            switch self {
            case .settings: return [.securitySettings, .appearanceSettings]
            case .appStore: return [.rateApp, .shareApp]
            case .feedback: return [.suggestImprove, .reportProblem]
            case .sourceCode: return [.sourceCode]
            case .design: return [.designer]
            case .donate: return [.donate]
            }
        }

        var title: String {
            switch self {
            case .settings: return "Настройки"
            case .appStore: return "App Store"
            case .feedback: return "Обратная связь"
            case .sourceCode: return "Авторы"
            case .design: return ""
            case .donate: return ""
            }
        }

        var subtitle: String? {
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

public protocol AppInfoRouter: AnyObject {
    func route(emailTheme: String, email: String)
    func route(url: String)
    func route(shareItem: UIActivityItemSource)
    func routePrivacySettings()
    func routeAppearanceSettings()
}

public class AppInfoPresenterImpl {

    // MARK: - Private

    private let sections: [Section] = [
        .settings,
        .appStore,
        .feedback,
        .sourceCode,
        .design,
        .donate
    ]

    private func route(emailTheme: String, email: String) {
        guard MFMailComposeViewController.canSendMail() else {
            output.show(
                message: "Для связи с разработчиком нужно добавить почтовый аккаунт в приложение «Почта»",
                okButton: "OK",
                infoButton: "Как это сделать"
            ) { [weak self] in self?.useCase.event(.emailInfo) }
            return
        }
        router.route(emailTheme: emailTheme, email: email)
    }

    // MARK: - Public

    public weak var output: SettingsPresenterOutput!
    public var useCase: AppInfoUseCase!
    public weak var router: AppInfoRouter!

    public init() {}
}

extension AppInfoPresenterImpl: SettingsPresenter {
    public var title: String { "О приложении" }

    public func event(switcher: Bool, indexPath: IndexPath) {
        fatalError()
    }

    public func eventViewReady() {
        output.show(sections: sections, update: [])
    }

    public func event(selectIndexPath: IndexPath) {
        switch sections[selectIndexPath.section].sectionRows[selectIndexPath.row] {
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

    public func presentPrivacySettings() {
        router.routePrivacySettings()
    }

    public func presentAppearanceSettings() {
        router.routeAppearanceSettings()
    }
}