import Foundation
import MessageUI
import UseCases

public enum AppInfoPresenterObjects {

    public enum Section {

        public enum Row {
            case promoRate
            case promoShare
            case contactSuggest
            case contactReport
            case designSuggest
            case infoSourceCode

            public var title: String {
                switch self {
                case .promoRate: return "Оценить приложение"
                case .promoShare: return "Поделиться приложением"
                case .contactSuggest: return "Предложить улучшение"
                case .contactReport: return "Сообщить о проблеме"
                case .designSuggest: return "Предложить дизайн"
                case .infoSourceCode: return "Посмотреть исходный код"
                }
            }
        }

        case promo
        case contact
        case design
        case info

        public var rows: [Row] {
            switch self {
            case .promo: return [.promoRate, .promoShare]
            case .contact: return [.contactSuggest, .contactReport]
            case .design: return [.designSuggest]
            case .info: return [.infoSourceCode]
            }
        }

        public var title: String {
            switch self {
            case .promo: return "App Store"
            case .contact: return "Связь с разработчиком"
            case .design: return "Дизайнерам"
            case .info: return "Другим разработчикам"
            }
        }

        public var subtitle: String? {
            switch self {
            case .promo: return nil
            case .contact: return nil
            case .design: return "Я умею программировать, но совсем плох в дизайне. Это приложение — лучшее, что я могу"
            case .info: return nil
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

    private let sections: [AppInfoPresenterObjects.Section] = [.promo, .contact, .design, .info]

    // MARK: - Public

    public weak var output: AppInfoPresenterOutput!
    public var useCase: AppInfoUseCase!
    public weak var router: AppInfoRouter!

    public init() {}

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
}

extension AppInfoPresenterImpl: AppInfoPresenter {
    public func eventViewReady() {
        output.show(sections: sections)
    }

    public func event(selectIndexPath: IndexPath) {
        switch sections[selectIndexPath.section].rows[selectIndexPath.row] {
        case .promoRate: useCase.event(.review)
        case .promoShare: useCase.event(.share)
        case .contactSuggest: useCase.event(.suggest)
        case .contactReport: useCase.event(.report)
        case .designSuggest: useCase.event(.designSuggest)
        case .infoSourceCode: useCase.event(.sourceCode)
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
