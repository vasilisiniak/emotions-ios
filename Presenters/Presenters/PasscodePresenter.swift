import UseCases

public protocol PasscodePresenterOutput: AnyObject {
    func present(info: String)
    func present(task: String)
    func present(error: String)
    func present(cancel: String)
    func present(total: Int, filled: Int)
}

public protocol PasscodeRouter: AnyObject {
    func routePasscodeCompleted(success: Bool)
}

public protocol PasscodePresenter {
    func eventViewReady()
    func event(input: Character)
    func eventCancel()
}

public final class PasscodePresenterImpl {

    // MARK: - Public

    public weak var output: PasscodePresenterOutput!
    public var useCase: PasscodeUseCase!
    public weak var router: PasscodeRouter!

    public init() {}
}

extension PasscodePresenterImpl: PasscodePresenter {

    public func eventViewReady() {
        output.present(cancel: "Отмена")
        useCase.eventOutputReady()
    }
    
    public func event(input: Character) {
        useCase.event(input: input)
    }
    
    public func eventCancel() {
        useCase.eventCancel()
    }
}

extension PasscodePresenterImpl: PasscodeUseCaseOutput {

    public func present(info: String) {
        output.present(info: info)
    }
    
    public func present(total: Int, filled: Int) {
        output.present(total: total, filled: filled)
    }
    
    public func present(state: UseCases.PasscodeUseCaseObjects.State) {
        switch state {
        case .enterNewPasscode:
            output.present(task: "Введите новый пароль")
        case .repeatNewPasscode:
            output.present(task: "Повторите новый пароль")
        case .enterPasscode:
            output.present(task: "Введите пароль")
        }
    }
    
    public func present(infoState: UseCases.PasscodeUseCaseObjects.InfoState?) {
        switch infoState {
        case .some(.invalidPasscode):
            output.present(error: "Неверный пароль")
        case .some(.passcodesNotMatching):
            output.present(error: "Пароли не совпадают")
        case .none:
            output.present(error: "")
        }
    }
    
    public func present(completed: Bool) {
        router.routePasscodeCompleted(success: completed)
    }
}
