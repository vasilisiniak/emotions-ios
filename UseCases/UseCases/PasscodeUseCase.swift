import Model

public enum PasscodeUseCaseObjects {

    public enum Mode {
        case setPasscode
        case checkPasscode
    }

    public enum State {
        case enterNewPasscode
        case repeatNewPasscode
        case enterPasscode
    }

    public enum InfoState {
        case passcodesNotMatching
        case invalidPasscode
    }
}

public protocol PasscodeUseCaseOutput: AnyObject {
    func present(info: String)
    func present(total: Int, filled: Int)
    func present(state: PasscodeUseCaseObjects.State)
    func present(infoState: PasscodeUseCaseObjects.InfoState?)
    func present(completed: Bool)
}

public protocol PasscodeUseCase {
    func eventOutputReady()
    func event(input: Character)
    func eventCancel()
}

public final class PasscodeUseCaseImpl {

    // MARK: - Private

    private let mode: PasscodeUseCaseObjects.Mode
    private let info: String
    private let passcodeManager: PasscodeManager
    private var newPasscode: String?
    private var input = ""

    // MARK: - Public

    public var completion: ((_ success: Bool) -> ())?
    public weak var output: PasscodeUseCaseOutput!

    public init(mode: PasscodeUseCaseObjects.Mode, info: String, passcodeManager: PasscodeManager) {
        self.mode = mode
        self.info = info
        self.passcodeManager = passcodeManager
    }
}

extension PasscodeUseCaseImpl: PasscodeUseCase {

    public func eventOutputReady() {
        output.present(info: info)

        switch mode {
        case .setPasscode:
            output.present(state: .enterNewPasscode)
            output.present(total: passcodeManager.length, filled: 0)
        case .checkPasscode:
            output.present(state: .enterPasscode)
            output.present(total: passcodeManager.length, filled: 0)
        }
    }
    
    public func event(input: Character) {

        self.input.append(input)

        output.present(total: passcodeManager.length, filled: self.input.count)
        output.present(infoState: nil)

        guard self.input.count == passcodeManager.length else { return }

        switch mode {

        case .setPasscode:
            if newPasscode == nil {
                newPasscode = self.input
                output.present(state: .repeatNewPasscode)
                output.present(total: passcodeManager.length, filled: 0)
            }
            else {
                if newPasscode == self.input {
                    let isSet = passcodeManager.set(passcode: self.input)
                    output.present(completed: isSet)
                    completion?(isSet)
                }
                else {
                    output.present(infoState: .passcodesNotMatching)
                    output.present(total: passcodeManager.length, filled: 0)
                }
            }

        case .checkPasscode:
            if passcodeManager.check(passcode: self.input) {
                output.present(completed: true)
                completion?(true)
            }
            else {
                output.present(infoState: .invalidPasscode)
                output.present(total: passcodeManager.length, filled: 0)
            }
        }

        self.input = ""
    }

    public func eventCancel() {
        output.present(completed: false)
        completion?(false)
    }
}
