import UIKit
import UseCases

public protocol TrendsPresenterOutput: class {
    func show(noDataText: String, button: String)
    func show(noDataHidden: Bool)
    func show(colors: [UIColor])
}

public protocol TrendsRouter: class {
    func routeEmotions()
}

public protocol TrendsPresenter {
    func eventViewReady()
    func eventAddTap()
}

public final class TrendsPresenterImpl {
    
    // MARK: - Public
    
    public weak var output: TrendsPresenterOutput!
    public weak var router: TrendsRouter!
    public var useCase: TrendsUseCase!
    
    public init() {}
}

extension TrendsPresenterImpl: TrendsPresenter {
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
    }
    
    public func present(noData: Bool) {
        output.show(noDataHidden: !noData)
    }
}
