import Foundation
import UseCases

fileprivate extension AppearanceSettingsPresenterImpl {

    enum Section: SettingsPresenterSection, Equatable {

        enum Row: SettingsPresenterRow, Equatable {

            case legacy(enabled: Bool)
            case compact(enabled: Bool)
            case legacyDiary(enabled: Bool)
            case reduceAnimation(enabled: Bool)

            var title: String {
                switch self {
                case .legacy: return "Старый вид эмоций"
                case .compact: return "Компактный вид дневника"
                case .legacyDiary: return "Старый вид дневника"
                case .reduceAnimation: return "Минимизировать анимацию"
                }
            }

            var style: SettingsPresenterRowStyle {
                switch self {
                case .legacy: return .switcher
                case .compact: return .switcher
                case .legacyDiary: return .switcher
                case .reduceAnimation: return .switcher
                }
            }

            var value: Any? {
                switch self {
                case .legacy(let enabled): return enabled
                case .compact(let enabled): return enabled
                case .legacyDiary(let enabled): return enabled
                case .reduceAnimation(let enabled): return enabled
                }
            }
        }

        case legacy(enabled: Bool)
        case compact(enabled: Bool)
        case legacyDiary(enabled: Bool)
        case reduceAnimation(enabled: Bool)

        var rows: [SettingsPresenterRow] { sectionRows }

        var sectionRows: [Row] {
            switch self {
            case .legacy(let enabled): return [.legacy(enabled: enabled)]
            case .compact(let enabled): return [.compact(enabled: enabled)]
            case .legacyDiary(let enabled): return [.legacyDiary(enabled: enabled)]
            case .reduceAnimation(let enabled): return [.reduceAnimation(enabled: enabled)]
            }
        }

        var title: String {
            switch self {
            case .legacy: return ""
            case .compact: return ""
            case .legacyDiary: return ""
            case .reduceAnimation: return ""
            }
        }

        var subtitle: String? {
            switch self {
            case .legacy: return "Использовать табличный список вместо баблов для эмоций"
            case .compact: return "Показывать дневник в однострочном режиме. Тап по ячейке показывает запись целиком"
            case .legacyDiary: return "Показывать эмоции в дневнике строкой вместо баблов"
            case .reduceAnimation: return "Убрать анимацию перемещения ячеек при выборе эмоций"
            }
        }
    }
}

public class AppearanceSettingsPresenterImpl {

    // MARK: - Private

    private var defaultSections: [Section] {
        sections(legacy: false, compact: true, legacyDiary: false, reduceAnimation: false)
    }

    private func sections(legacy: Bool, compact: Bool, legacyDiary: Bool, reduceAnimation: Bool) -> [Section] {
        [
            .legacy(enabled: legacy),
            .compact(enabled: compact),
            .legacyDiary(enabled: legacyDiary),
            .reduceAnimation(enabled: reduceAnimation)
        ]
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
        case .legacy: useCase.event(legacy: switcher)
        case .compact: useCase.event(compact: switcher)
        case .legacyDiary: useCase.event(legacyDiary: switcher)
        case .reduceAnimation: useCase.event(reduceAnimation: switcher)
        }
    }

    public func event(selectIndexPath: IndexPath) {
        switch defaultSections[selectIndexPath.section].sectionRows[selectIndexPath.row] {
        case .legacy: fatalError()
        case .compact: fatalError()
        case .legacyDiary: fatalError()
        case .reduceAnimation: fatalError()
        }
    }
}

extension AppearanceSettingsPresenterImpl: AppearanceSettingsUseCaseOutput {
    public func present(legacy: Bool, compact: Bool, reduceAnimation: Bool, legacyDiary: Bool) {
        let sections = sections(theme: theme, legacy: legacy, compact: compact, legacyDiary: legacyDiary, reduceAnimation: reduceAnimation)
        let update = sections.enumerated().flatMap { index, section in
            section.sectionRows.enumerated().map { row, _ in IndexPath(row: row, section: index) }
        }
        output.show(sections: sections, update: update)
    }
}
