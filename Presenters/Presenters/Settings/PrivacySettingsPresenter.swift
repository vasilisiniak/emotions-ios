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

        case protect(protect: Bool)
        case faceId(faceId: Bool)

        var rows: [SettingsPresenterRow] { sectionRows }

        var sectionRows: [Row] {
            switch self {
            case .protect(let protect): return [Row.protect(protect: protect)]
            case .faceId(let faceId): return [Row.faceId(enabled: faceId)]
            }
        }

        var title: String {
            switch self {
            case .protect: return ""
            case .faceId: return ""
            }
        }

        var subtitle: String? {
            switch self {
            case .protect: return "Замылить личные страницы приложения, когда оно отображается в списке открытых"
            case .faceId: return "Для изменения типа защиты между FaceID/TouchID и своим паролем выключите защиту и включите снова"
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
        [.protect(protect: protect), .faceId(faceId: faceId)]
    }

    private func chooseLock(indexPath: IndexPath) {
        func handler(_ mode: PrivacySettingsUseCaseObjects.LockMode) -> () -> () {
            { [useCase] in useCase?.eventEnableLock(mode: mode, info: "Включить защиту паролем") }
        }
        output.show(options: [
            ("Стандартная защита телефона", handler(.system)),
            ("Свой пароль", handler(.passcode))
        ], cancel: ("Отмена", { [output] in output?.show(reload: indexPath) }))
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
        useCase.eventViewReady()
    }

    public func event(switcher: Bool, indexPath: IndexPath) {
        switch sections(protect: false, faceId: false)[indexPath.section].sectionRows[indexPath.row] {
        case .protect: useCase.event(protect: switcher, info: "Отключить защиту паролем")
        case .faceId:
            if switcher {
                chooseLock(indexPath: indexPath)
            }
            else {
                useCase.eventDisableLock(info: "Отключить защиту паролем")
            }
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
        let update = sections.enumerated().flatMap { index, section in
            section.sectionRows.enumerated().map { row, _ in IndexPath(row: row, section: index) }
        }
        output.show(sections: sections, update: update)
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
