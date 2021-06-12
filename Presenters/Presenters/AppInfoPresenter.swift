import Foundation
import MessageUI
import LinkPresentation
import Utils

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

    private func share() {
        let item = LinkActivityItem(title: Bundle.main.appName, url: URL(string: "https://apps.apple.com/app/id1558896129"), icon: Bundle.main.appIcon)
        router.route(shareItem: item)
    }
}

extension AppInfoPresenterImpl: AppInfoPresenter {
    public func eventViewReady() {
        output.show(sections: sections)
    }

    public func event(selectIndexPath: IndexPath) {
        switch sections[selectIndexPath.section].rows[selectIndexPath.row] {
        case .promoRate: router.route(url: "https://apps.apple.com/app/id1558896129?action=write-review")
        case .promoShare: share()
        case .contactSuggest: route(emailTheme: "[Emotions][Suggest]", email: "vasili.siniak+emotions@gmail.com")
        case .contactReport: route(emailTheme: "[Emotions][Report]", email: "vasili.siniak+emotions@gmail.com")
        case .designSuggest: route(emailTheme: "[Emotions][Design]", email: "vasili.siniak+emotions@gmail.com")
        case .infoSourceCode: router.route(url: "https://github.com/vasilisiniak/emotions-ios")
        }
    }

    public func eventEmailInfo() {
        UIApplication.shared.open(URL(string: "https://support.apple.com/ru-ru/HT201320")!)
    }
}
