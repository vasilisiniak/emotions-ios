import Foundation
import MessageUI
import UseCases

public enum AppInfoPresenterObjects {

    public enum Section: Equatable {

        public enum Row: Equatable {

            public enum Style {
                case disclosure
                case switcher
            }

            case promoRate
            case promoShare
            case contactSuggest
            case contactReport
            case designSuggest
            case infoSourceCode
            case donate
            case protect(protect: Bool)

            public var title: String {
                switch self {
                case .promoRate: return "Оценить приложение"
                case .promoShare: return "Поделиться приложением"
                case .contactSuggest: return "Предложить улучшение"
                case .contactReport: return "Сообщить о проблеме"
                case .designSuggest: return "Предложить дизайн"
                case .infoSourceCode: return "Посмотреть исходный код"
                case .donate: return "Поддержать разработчика"
                case .protect: return "Прятать личные данные"
                }
            }

            public var style: Style {
                switch self {
                case .protect: return .switcher
                default: return .disclosure
                }
            }

            public var value: Any? {
                switch self {
                case .protect(let protect): return protect
                default: return nil
                }
            }
        }

        case promo
        case contact
        case donate
        case design
        case info
        case settings(protect: Bool)

        public var rows: [Row] {
            switch self {
            case .promo: return [.promoRate, .promoShare]
            case .contact: return [.contactSuggest, .contactReport]
            case .donate: return [.donate]
            case .design: return [.designSuggest]
            case .info: return [.infoSourceCode]
            case .settings(let protect): return [.protect(protect: protect)]
            }
        }

        public var title: String {
            switch self {
            case .promo: return "App Store"
            case .contact: return "Связь с разработчиком"
            case .donate: return ""
            case .design: return "Дизайнерам"
            case .info: return "Другим разработчикам"
            case .settings: return "Настройки"
            }
        }

        public var subtitle: String? {
            switch self {
            case .promo: return nil
            case .contact: return nil
            case .donate: return "Это вовсе не обязательно! Но я буду очень благодарен :)"
            case .design: return "Я умею программировать, но совсем плох в дизайне. Это приложение — лучшее, что я могу"
            case .info: return nil
            case .settings: return "Замылить некоторые страницы приложения, когда оно отображается в списке открытых"
            }
        }
    }
}

public protocol AppInfoPresenterOutput: AnyObject {
    func show(sections: [AppInfoPresenterObjects.Section], update: IndexPath?)
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
    func event(switcher: Bool, indexPath: IndexPath)
}

public class AppInfoPresenterImpl {

    // MARK: - Private

    private func sections(protect: Bool = false) -> [AppInfoPresenterObjects.Section] {
        [.settings(protect: protect), .promo, .contact, .donate, .design, .info]
    }

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
    public func event(switcher: Bool, indexPath: IndexPath) {
        switch sections()[indexPath.section].rows[indexPath.row] {
        case .protect: useCase.event(protect: switcher)
        default: fatalError()
        }
    }

    public func eventViewReady() {
        output.show(sections: sections(protect: false), update: nil)
        useCase.eventViewReady()
    }

    public func event(selectIndexPath: IndexPath) {
        switch sections()[selectIndexPath.section].rows[selectIndexPath.row] {
        case .promoRate: useCase.event(.review)
        case .promoShare: useCase.event(.share)
        case .contactSuggest: useCase.event(.suggest)
        case .contactReport: useCase.event(.report)
        case .designSuggest: useCase.event(.designSuggest)
        case .infoSourceCode: useCase.event(.sourceCode)
        case .donate: useCase.event(.donate)
        case .protect: fatalError()
        }
    }

    public func eventEmailInfo() {
        useCase.event(.emailInfo)
    }
}

extension AppInfoPresenterImpl: AppInfoUseCaseOutput {
    public func present(protect: Bool) {
        let sections = sections(protect: protect)
        let section = sections.firstIndex(of: .settings(protect: protect))!
        let row = AppInfoPresenterObjects.Section.settings(protect: protect).rows.firstIndex(of: .protect(protect: protect))!

        output.show(sections: sections, update: IndexPath(row: row, section: section))
    }

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
