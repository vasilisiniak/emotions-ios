import UIKit
import UseCases

public enum TrendsPresenterObjects {

    public struct Stat {

        // MARK: - Internal

        init(stats: TrendsUseCaseObjects.Stat, max: Double) {
            name = stats.name
            color = UIColor(hex: stats.color)
            frequency = stats.frequency / max
        }

        // MARK: - Public

        public let name: String
        public let color: UIColor
        public let frequency: Double
    }
}

public protocol TrendsPresenterOutput: AnyObject {
    func show(noDataText: String, button: String?)
    func show(rangeTitle: String)
    func show(range: (min: Date, max: Date))
    func show(selectedRange: (min: Date?, max: Date?))
    func show(noDataHidden: Bool)
    func show(rangeHidden: Bool)
    func show(colors: [UIColor])
    func show(stats: [TrendsPresenterObjects.Stat])
}

public protocol TrendsRouter: AnyObject {
    func routeEmotions()
}

public protocol TrendsPresenter {
    func eventViewReady()
    func eventAddTap()
    func event(selectedRange: (min: Date?, max: Date?))
}

public final class TrendsPresenterImpl {

    // MARK: - Public

    public weak var output: TrendsPresenterOutput!
    public weak var router: TrendsRouter!
    public var useCase: TrendsUseCase!

    public init() {}
}

extension TrendsPresenterImpl: TrendsPresenter {
    public func event(selectedRange: (min: Date?, max: Date?)) {
        useCase.event(selectedRange: selectedRange)
    }

    public func eventAddTap() {
        useCase.eventAdd()
    }

    public func eventViewReady() {
        output.show(noDataText: "Здесь отображаются цветовая карта эмоций. Но пока записей недостаточно", button: "Добавить запись")
        useCase.eventOutputReady()
    }
}

extension TrendsPresenterImpl: TrendsUseCaseOutput {
    public func presentEmotions() {
        router.routeEmotions()
    }

    public func present(colors: [String]) {
        output.show(colors: colors.map(UIColor.init(hex:)))
        output.show(rangeTitle: "Выбрано записей: \(colors.count)")
    }

    public func present(stats: [TrendsUseCaseObjects.Stat]) {
        guard let max = stats.map(\.frequency).max() else {
            output.show(stats: [])
            return
        }
        output.show(stats: stats.map { TrendsPresenterObjects.Stat(stats: $0, max: max * 1.05) })
    }

    public func present(noData: Bool, becauseOfRange: Bool) {
        output.show(noDataHidden: !noData)
        output.show(rangeHidden: noData && !becauseOfRange)

        guard noData else { return }

        if becauseOfRange {
            output.show(noDataText: "Нет записей в выбранном диапазоне", button: nil)
        }
        else {
            output.show(noDataText: "Здесь отображаются цветовая карта эмоций. Но пока записей недостаточно", button: "Добавить запись")
        }
    }

    public func present(range: (min: Date, max: Date)) {
        output.show(range: range)
    }

    public func present(selectedRange: (min: Date?, max: Date?)) {
        output.show(selectedRange: selectedRange)
    }
}
