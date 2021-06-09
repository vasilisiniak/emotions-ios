import Foundation
import MessageUI

public enum AppInfoPresenterObjects {

    public enum Section {

        public enum Row {
            case contactSuggest
            case contactReport
            case designSuggest
            case infoSourceCode

            public var title: String {
                switch self {
                case .contactSuggest: return "Предложить улучшение"
                case .contactReport: return "Сообщить о проблеме"
                case .designSuggest: return "Предложить дизайн"
                case .infoSourceCode: return "Посмотреть исходный код"
                }
            }
        }

        case contact
        case design
        case info

        public var rows: [Row] {
            switch self {
            case .contact: return [.contactSuggest, .contactReport]
            case .design: return [.designSuggest]
            case .info: return [.infoSourceCode]
            }
        }

        public var title: String {
            switch self {
            case .contact: return "Связь с разработчиком"
            case .design: return "Дизайнерам"
            case .info: return "Другим разработчикам"
            }
        }

        public var subtitle: String? {
            switch self {
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
}

public protocol AppInfoPresenter {
    func eventViewReady()
    func eventEmailInfo()
    func event(selectIndexPath: IndexPath)
}

public class AppInfoPresenterImpl {

    // MARK: - Private

    private let sections: [AppInfoPresenterObjects.Section] = [.contact, .design, .info]

    // MARK: - Public

    public weak var output: AppInfoPresenterOutput!
    public weak var router: AppInfoRouter!

    public init() {}
}

extension AppInfoPresenterImpl: AppInfoPresenter {
    public func eventViewReady() {
        output.show(sections: sections)
    }

    public func event(selectIndexPath: IndexPath) {
        guard MFMailComposeViewController.canSendMail() else {
            output.showEmailAlert(
                message: "Для связи с разработчиком нужно добавить почтовый аккаунт в приложение «Почта»",
                okButton: "OK",
                infoButton: "Как это сделать"
            )
            return
        }

        switch sections[selectIndexPath.section].rows[selectIndexPath.row] {
        case .contactSuggest: router.route(emailTheme: "[Emotions][Suggest]", email: "vasili.siniak+emotions@gmail.com")
        case .contactReport: router.route(emailTheme: "[Emotions][Report]", email: "vasili.siniak+emotions@gmail.com")
        case .designSuggest: router.route(emailTheme: "[Emotions][Design]", email: "vasili.siniak+emotions@gmail.com")
        case .infoSourceCode: router.route(url: "https://github.com/vasilisiniak/emotions-ios")
        }
    }

    public func eventEmailInfo() {
        UIApplication.shared.open(URL(string: "https://support.apple.com/ru-ru/HT201320")!)
    }
}
