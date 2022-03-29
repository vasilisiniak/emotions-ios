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
            case designer
            case infoSourceCode
            case donate
            case protect(protect: Bool)
            case faceId(enabled: Bool)
            case legacy(enabled: Bool)
            case compact(enabled: Bool)
            case legacyDiary(enabled: Bool)
            case reduceAnimation(enabled: Bool)

            public var title: String {
                switch self {
                case .promoRate: return "Оценить приложение"
                case .promoShare: return "Поделиться приложением"
                case .contactSuggest: return "Предложить улучшение"
                case .contactReport: return "Сообщить о проблеме"
                case .designer: return "Сергей Грабинский"
                case .infoSourceCode: return "Посмотреть исходный код"
                case .donate: return "Поддержать разработчика"
                case .protect: return "Прятать личные данные"
                case .faceId: return "Защитить паролем"
                case .legacy: return "Старый вид эмоций"
                case .compact: return "Компактный вид дневника"
                case .legacyDiary: return "Старый вид дневника"
                case .reduceAnimation: return "Минимизировать анимацию"
                }
            }

            public var style: Style {
                switch self {
                case .protect: return .switcher
                case .faceId: return .switcher
                case .legacy: return .switcher
                case .compact: return .switcher
                case .legacyDiary: return .switcher
                case .reduceAnimation: return .switcher
                default: return .disclosure
                }
            }

            public var value: Any? {
                switch self {
                case .protect(let protect): return protect
                case .faceId(let enabled): return enabled
                case .legacy(let enabled): return enabled
                case .compact(let enabled): return enabled
                case .legacyDiary(let enabled): return enabled
                case .reduceAnimation(let enabled): return enabled
                default: return nil
                }
            }
        }

        case promo
        case contact
        case donate
        case design
        case info
        case settings(protect: Bool, faceId: Bool)
        case legacy(enabled: Bool)
        case compact(enabled: Bool)
        case legacyDiary(enabled: Bool)
        case reduceAnimation(enabled: Bool)

        public var rows: [Row] {
            switch self {
            case .promo: return [.promoRate, .promoShare]
            case .contact: return [.contactSuggest, .contactReport]
            case .donate: return [.donate]
            case .design: return [.designer]
            case .info: return [.infoSourceCode]
            case .settings(let protect, let faceId): return [.protect(protect: protect), .faceId(enabled: faceId)]
            case .legacy(let enabled): return [.legacy(enabled: enabled)]
            case .compact(let enabled): return [.compact(enabled: enabled)]
            case .legacyDiary(let enabled): return [.legacyDiary(enabled: enabled)]
            case .reduceAnimation(let enabled): return [.reduceAnimation(enabled: enabled)]
            }
        }

        public var title: String {
            switch self {
            case .promo: return "App Store"
            case .contact: return "Обратная связь"
            case .donate: return ""
            case .design: return "Дизайн"
            case .info: return "Разработчикам"
            case .settings: return "Настройки"
            case .legacy: return ""
            case .compact: return ""
            case .legacyDiary: return ""
            case .reduceAnimation: return ""
            }
        }

        public var subtitle: String? {
            switch self {
            case .promo: return nil
            case .contact: return nil
            case .donate: return "Для развития этого приложения и создания новых"
            case .design: return "Советы и идеи по UI/UX и всякому разному"
            case .info: return nil
            case .settings: return "Замылить некоторые страницы приложения, когда оно отображается в списке открытых"
            case .legacy: return "Использовать табличный список вместо баблов для эмоций"
            case .compact: return "Показывать дневник в однострочном режиме. Тап по ячейке показывает запись целиком"
            case .legacyDiary: return "Показывать эмоции в дневнике строкой вместо баблов"
            case .reduceAnimation: return "Убрать анимацию перемещения ячеек при выборе эмоций"
            }
        }
    }
}

public protocol AppInfoPresenterOutput: AnyObject {
    func show(sections: [AppInfoPresenterObjects.Section], update: [IndexPath])
    func showEmailAlert(message: String, okButton: String, infoButton: String)
    func showFaceIdAlert(message: String, okButton: String, infoButton: String)
}

public protocol AppInfoRouter: AnyObject {
    func route(emailTheme: String, email: String)
    func route(url: String)
    func route(shareItem: UIActivityItemSource)
}

public protocol AppInfoPresenter {
    func eventViewReady()
    func eventEmailInfo()
    func eventFaceIdInfo()
    func event(selectIndexPath: IndexPath)
    func event(switcher: Bool, indexPath: IndexPath)
}

public class AppInfoPresenterImpl {

    // MARK: - Private

    private var defaultSections: [AppInfoPresenterObjects.Section] {
        sections(protect: false, faceId: false, legacy: false, compact: true, legacyDiary: false, reduceAnimation: false)
    }

    private func sections(protect: Bool, faceId: Bool, legacy: Bool, compact: Bool, legacyDiary: Bool, reduceAnimation: Bool) -> [AppInfoPresenterObjects.Section] {
        [
            .settings(protect: protect, faceId: faceId),
            .legacy(enabled: legacy),
            .compact(enabled: compact),
            .legacyDiary(enabled: legacyDiary),
            .reduceAnimation(enabled: reduceAnimation),
            .promo,
            .contact,
            .design,
            .info,
            .donate
        ]
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
        switch defaultSections[indexPath.section].rows[indexPath.row] {
        case .protect: useCase.event(protect: switcher, info: "Отключить защиту паролем")
        case .faceId: useCase.event(faceId: switcher, info: switcher ? "Включить защиту паролем" : "Отключить защиту паролем")
        case .legacy: useCase.event(legacy: switcher)
        case .compact: useCase.event(compact: switcher)
        case .legacyDiary: useCase.event(legacyDiary: switcher)
        case .reduceAnimation: useCase.event(reduceAnimation: switcher)
        default: fatalError()
        }
    }

    public func eventViewReady() {
        output.show(sections: defaultSections, update: [])
        useCase.eventViewReady()
    }

    public func event(selectIndexPath: IndexPath) {
        switch defaultSections[selectIndexPath.section].rows[selectIndexPath.row] {
        case .promoRate: useCase.event(.review)
        case .promoShare: useCase.event(.share)
        case .contactSuggest: useCase.event(.suggest)
        case .contactReport: useCase.event(.report)
        case .designer: useCase.event(.designer)
        case .infoSourceCode: useCase.event(.sourceCode)
        case .donate: useCase.event(.donate)
        case .protect: fatalError()
        case .faceId: fatalError()
        case .legacy: fatalError()
        case .compact: fatalError()
        case .legacyDiary: fatalError()
        case .reduceAnimation: fatalError()
        }
    }

    public func eventEmailInfo() {
        useCase.event(.emailInfo)
    }

    public func eventFaceIdInfo() {
        useCase.event(.faceIdInfo)
    }
}

extension AppInfoPresenterImpl: AppInfoUseCaseOutput {
    public func present(protect: Bool, faceId: Bool, legacy: Bool, compact: Bool, reduceAnimation: Bool, legacyDiary: Bool) {
        let sections = sections(protect: protect, faceId: faceId, legacy: legacy, compact: compact, legacyDiary: legacyDiary, reduceAnimation: reduceAnimation)

        let protectSection = sections.firstIndex(of: .settings(protect: protect, faceId: faceId))!
        let protectRow = AppInfoPresenterObjects.Section.settings(protect: protect, faceId: faceId).rows.firstIndex(of: .protect(protect: protect))!
        let faceIdRow = AppInfoPresenterObjects.Section.settings(protect: protect, faceId: faceId).rows.firstIndex(of: .faceId(enabled: faceId))!

        let legacySection = sections.firstIndex(of: .legacy(enabled: legacy))!
        let legacyRow = AppInfoPresenterObjects.Section.legacy(enabled: legacy).rows.firstIndex(of: .legacy(enabled: legacy))!

        let compactSection = sections.firstIndex(of: .compact(enabled: compact))!
        let compactRow = AppInfoPresenterObjects.Section.compact(enabled: compact).rows.firstIndex(of: .compact(enabled: compact))!

        let reduceSection = sections.firstIndex(of: .reduceAnimation(enabled: reduceAnimation))!
        let reduceRow = AppInfoPresenterObjects.Section.reduceAnimation(enabled: reduceAnimation).rows.firstIndex(of: .reduceAnimation(enabled: reduceAnimation))!

        let legacyDiarySection = sections.firstIndex(of: .legacyDiary(enabled: legacyDiary))!
        let legacyDiaryRow = AppInfoPresenterObjects.Section.legacyDiary(enabled: legacyDiary).rows.firstIndex(of: .legacyDiary(enabled: legacyDiary))!

        output.show(sections: sections, update: [
            IndexPath(row: protectRow, section: protectSection),
            IndexPath(row: faceIdRow, section: protectSection),
            IndexPath(row: legacyRow, section: legacySection),
            IndexPath(row: compactRow, section: compactSection),
            IndexPath(row: reduceRow, section: reduceSection),
            IndexPath(row: legacyDiaryRow, section: legacyDiarySection)
        ])
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

    public func presentFaceIdError() {
        output.showFaceIdAlert(
            message: "Для функции защиты паролем нужно включить код-пароль в настройках устройства",
            okButton: "OK",
            infoButton: "Как это сделать"
        )
    }
}
