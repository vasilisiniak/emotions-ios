import UIKit
import UseCases

public protocol TrendsPresenterOutput: class {
    func show(colors: [UIColor])
}

public protocol TrendsPresenter {
    func eventViewReady()
}

public final class TrendsPresenterImpl {
    
    // MARK: - Public
    
    public weak var output: TrendsPresenterOutput!
    public var useCase: TrendsUseCase!
    
    public init() {}
}

extension TrendsPresenterImpl: TrendsPresenter {
    public func eventViewReady() {
        useCase.eventOutputReady()
    }
}

extension TrendsPresenterImpl: TrendsUseCaseOutput {
    public func present(colors: [String]) {
        var colors = colors.map { UIColor(hex: $0) }
        if colors.count == 0 {
            colors.append(.white)
            colors.append(.white)
        }
        else if colors.count == 1 {
            colors.append(colors.first!)
        }
        output.show(colors: colors)
    }
}
