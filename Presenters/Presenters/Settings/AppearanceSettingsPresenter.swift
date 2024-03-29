import Foundation
import UseCases
import UIKit

fileprivate extension UIUserInterfaceStyle {
    var name: String {
        switch self {
        case .unspecified: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Тёмная"
        @unknown default: fatalError()
        }
    }
}

fileprivate extension AppearanceSettingsPresenterImpl {

    enum Section: SettingsPresenterSection, Equatable {

        enum Row: SettingsPresenterRow, Equatable {

            case theme(style: UIUserInterfaceStyle)
            case legacy(enabled: Bool)
            case compact(enabled: Bool)
            case legacyDiary(enabled: Bool)
            case reduceAnimation(enabled: Bool)
            case trash(enabled: Bool)
            case percentage(enabled: Bool)
            case colorDiary(enabled: Bool)

            var title: String {
                switch self {
                case .theme: return "Тема"
                case .legacy: return "Старый вид эмоций"
                case .compact: return "Компактный вид дневника"
                case .legacyDiary: return "Старый вид дневника"
                case .reduceAnimation: return "Минимизировать анимацию"
                case .trash: return "Удалять в корзину"
                case .percentage: return "Показывать % эмоций"
                case .colorDiary: return "Цветные записи в дневнике"
                }
            }

            var style: SettingsPresenterRowStyle {
                switch self {
                case .theme: return .option
                case .legacy: return .switcher
                case .compact: return .switcher
                case .legacyDiary: return .switcher
                case .reduceAnimation: return .switcher
                case .trash: return .switcher
                case .percentage: return .switcher
                case .colorDiary: return .switcher
                }
            }

            var value: Any? {
                switch self {
                case .theme(let style): return style.name
                case .legacy(let enabled): return enabled
                case .compact(let enabled): return enabled
                case .legacyDiary(let enabled): return enabled
                case .reduceAnimation(let enabled): return enabled
                case .trash(let enabled): return enabled
                case .percentage(let enabled): return enabled
                case .colorDiary(let enabled): return enabled
                }
            }
        }

        case theme(style: UIUserInterfaceStyle)
        case legacy(enabled: Bool)
        case compact(enabled: Bool)
        case legacyDiary(enabled: Bool)
        case reduceAnimation(enabled: Bool)
        case trash(enabled: Bool)
        case percentage(enabled: Bool)
        case colorDiary(enabled: Bool)

        var rows: [SettingsPresenterRow] { sectionRows }

        var sectionRows: [Row] {
            switch self {
            case .theme(let style): return [.theme(style: style)]
            case .legacy(let enabled): return [.legacy(enabled: enabled)]
            case .compact(let enabled): return [.compact(enabled: enabled)]
            case .legacyDiary(let enabled): return [.legacyDiary(enabled: enabled)]
            case .reduceAnimation(let enabled): return [.reduceAnimation(enabled: enabled)]
            case .trash(let enabled): return [.trash(enabled: enabled)]
            case .percentage(let enabled): return [.percentage(enabled: enabled)]
            case .colorDiary(let enabled): return [.colorDiary(enabled: enabled)]
            }
        }

        var title: String {
            switch self {
            case .theme: return ""
            case .legacy: return "Список эмоций"
            case .compact: return ""
            case .legacyDiary: return ""
            case .reduceAnimation: return ""
            case .trash: return "Дневник"
            case .percentage: return "Цветовая карта"
            case .colorDiary: return ""
            }
        }

        var subtitle: String? {
            switch self {
            case .theme: return ""
            case .legacy: return "Использовать табличный список вместо баблов для эмоций"
            case .compact: return "Показывать дневник в однострочном режиме. Тап по ячейке показывает запись целиком"
            case .legacyDiary: return "Показывать эмоции в дневнике строкой вместо баблов"
            case .reduceAnimation: return "Убрать анимацию перемещения ячеек при выборе эмоций"
            case .trash: return "Удалять записи дневника сначала в корзину: из неё их можно удалить навсегда либо восстановить. Записи хранятся в корзине 3 дня, а затем удаляются автоматически"
            case .percentage: return "Показывать частоту использования эмоций в процентах в разделе карты эмоций"
            case .colorDiary: return "Красить фон записи в дневнике в цвет самой сильной эмоции"
            }
        }
    }
}

public class AppearanceSettingsPresenterImpl {

    // MARK: - Private

    private var defaultSections: [Section] {
        sections(theme: .unspecified, legacy: false, compact: true, legacyDiary: false, reduceAnimation: false, trash: true, percentage: false, colorDiary: false)
    }

    private func sections(
        theme: UIUserInterfaceStyle,
        legacy: Bool,
        compact: Bool,
        legacyDiary: Bool,
        reduceAnimation: Bool,
        trash: Bool,
        percentage: Bool,
        colorDiary: Bool
    ) -> [Section] {
        [
            .theme(style: theme),
            .legacy(enabled: legacy),
            .reduceAnimation(enabled: reduceAnimation),
            .trash(enabled: trash),
            .colorDiary(enabled: colorDiary),
            .compact(enabled: compact),
            .legacyDiary(enabled: legacyDiary),
            .percentage(enabled: percentage)
        ]
    }

    private func showAppearance() {
        func handler(_ theme: UIUserInterfaceStyle) -> () -> () {
            { [weak self] in self?.useCase.event(theme: theme) }
        }
        output.show(options: [
            ("Системная", handler(.unspecified)),
            ("Светлая", handler(.light)),
            ("Тёмная", handler(.dark))
        ], cancel: "Отмена")
    }

    // MARK: - Public

    public weak var output: SettingsPresenterOutput!
    public var useCase: AppearanceSettingsUseCase!

    public init() {}
}

extension AppearanceSettingsPresenterImpl: SettingsPresenter {
    public var title: String { "Отображение" }

    public func eventViewReady() {
        useCase.eventViewReady()
    }

    public func event(switcher: Bool, indexPath: IndexPath) {
        switch defaultSections[indexPath.section].sectionRows[indexPath.row] {
        case .theme: fatalError()
        case .trash: useCase.event(trash: switcher)
        case .legacy: useCase.event(legacy: switcher)
        case .compact: useCase.event(compact: switcher)
        case .legacyDiary: useCase.event(legacyDiary: switcher)
        case .reduceAnimation: useCase.event(reduceAnimation: switcher)
        case .percentage: useCase.event(percentage: switcher)
        case .colorDiary: useCase.event(colorDiary: switcher)
        }
    }

    public func event(selectIndexPath: IndexPath) {
        switch defaultSections[selectIndexPath.section].sectionRows[selectIndexPath.row] {
        case .theme: showAppearance()
        case .trash: fatalError()
        case .legacy: fatalError()
        case .compact: fatalError()
        case .legacyDiary: fatalError()
        case .reduceAnimation: fatalError()
        case .percentage: fatalError()
        case .colorDiary: fatalError()
        }
    }
}

extension AppearanceSettingsPresenterImpl: AppearanceSettingsUseCaseOutput {
    public func present(
        theme: UIUserInterfaceStyle,
        legacy: Bool,
        compact: Bool,
        reduceAnimation: Bool,
        legacyDiary: Bool,
        trash: Bool,
        percentage: Bool,
        colorDiary: Bool
    ) {
        let sections = sections(
            theme: theme,
            legacy: legacy,
            compact: compact,
            legacyDiary: legacyDiary,
            reduceAnimation: reduceAnimation,
            trash: trash,
            percentage: percentage,
            colorDiary: colorDiary
        )
        let update = sections.enumerated().flatMap { index, section in
            section.sectionRows.enumerated().map { row, _ in IndexPath(row: row, section: index) }
        }
        output.show(sections: sections, update: update)
    }

    public func presentTrashNotEmpty() {
        output.show(message: "Корзина не пуста: удалите или восстановите записи из корзины перед её отключением", okButton: "OK", infoButton: nil, okHandler: nil)
    }
}
