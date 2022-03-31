import Foundation
import UseCases

fileprivate extension PrivacySettingsPresenterImpl {

    enum Section: SettingsPresenterSection, Equatable {

        enum Row: SettingsPresenterRow, Equatable {

            case protect(protect: Bool)
            case faceId(enabled: Bool)

            var title: String {
                switch self {
                case .protect: return "Прятать личные данные"
                case .faceId: return "Защитить паролем"
                }
            }

            var style: SettingsPresenterRowStyle {
                switch self {
                case .protect: return .switcher
                case .faceId: return .switcher
                }
            }

            var value: Any? {
                switch self {
                case .protect(let protect): return protect
                case .faceId(let enabled): return enabled
                }
            }
        }

        case settings(protect: Bool, faceId: Bool)

        var rows: [SettingsPresenterRow] { sectionRows }

        var sectionRows: [Row] {
            switch self {
            case .settings(let protect, let faceId): return [Row.protect(protect: protect), Row.faceId(enabled: faceId)]
            }
        }

        var title: String {
            switch self {
            case .settings: return ""
            }
        }

        var subtitle: String? {
            switch self {
            case .settings: return "Замылить некоторые страницы приложения, когда оно отображается в списке открытых"
            }
        }
    }
}

public protocol PrivacySettingsRouter: AnyObject {
    func route(url: String)
}

public class PrivacySettingsPresenterImpl {

    // MARK: - Private

    private func sections(protect: Bool, faceId: Bool) -> [Section] {
        [.settings(protect: protect, faceId: faceId)]
    }

    // MARK: - Public

    public weak var output: SettingsPresenterOutput!
    public var useCase: PrivacySettingsUseCase!
    public weak var router: PrivacySettingsRouter!

    public init() {}
}

extension PrivacySettingsPresenterImpl: SettingsPresenter {
    public var title: String { "Приватность" }

    public func eventViewReady() {
        output.show(sections: sections(protect: false, faceId: false), update: [])
    }

    public func event(switcher: Bool, indexPath: IndexPath) {
        switch sections(protect: false, faceId: false)[indexPath.section].sectionRows[indexPath.row] {
        case .protect: useCase.event(protect: switcher, info: "Отключить защиту паролем")
        case .faceId: useCase.event(faceId: switcher, info: switcher ? "Включить защиту паролем" : "Отключить защиту паролем")
        }
    }

    public func event(selectIndexPath: IndexPath) {
        switch sections(protect: false, faceId: false)[selectIndexPath.section].sectionRows[selectIndexPath.row] {
        case .protect: fatalError()
        case .faceId: fatalError()
        }
    }
}

extension PrivacySettingsPresenterImpl: PrivacySettingsUseCaseOutput {
    public func present(protect: Bool, faceId: Bool) {
        let sections = sections(protect: protect, faceId: faceId)

        let protectSection = sections.firstIndex(of: .settings(protect: protect, faceId: faceId))!
        let protectRow = Section.settings(protect: protect, faceId: faceId).sectionRows.firstIndex(of: .protect(protect: protect))!
        let faceIdRow = Section.settings(protect: protect, faceId: faceId).sectionRows.firstIndex(of: .faceId(enabled: faceId))!

        output.show(sections: sections, update: [
            IndexPath(row: protectRow, section: protectSection),
            IndexPath(row: faceIdRow, section: protectSection)
        ])
    }

    public func present(url: String) {
        router.route(url: url)
    }

    public func presentFaceIdError() {
        output.show(
            message: "Для функции защиты паролем нужно включить код-пароль в настройках устройства",
            okButton: "OK",
            infoButton: "Как это сделать"
        ) { [weak self] in self?.useCase?.eventFaceIdInfo() }
    }
}
