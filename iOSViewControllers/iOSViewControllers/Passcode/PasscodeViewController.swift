import UIKit
import Presenters

public final class PasscodeViewController: UIViewController {

    // MARK: - UIViewController

    public override func loadView() {
        view = passcodeView
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        for i in passcodeView.keypad.buttons.indices {
            let button = passcodeView.keypad.buttons[i].view
            let char = "\(i)".first!

            button.addAction(UIAction { [presenter] _ in
                presenter?.event(input: char)
            }, for: .touchUpInside)
        }

        passcodeView.cancel.addAction(UIAction { [presenter] _ in
            presenter?.eventCancel()
        }, for: .touchUpInside)

        presenter.eventViewReady()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        passcodeView.passcode.updateColors()
    }

    // MARK: - Private

    private let passcodeView = View()

    // MARK: - Public

    public var presenter: PasscodePresenter!
}

extension PasscodeViewController: PasscodePresenterOutput {

    public func present(info: String) {
        passcodeView.info.text = info
    }
    
    public func present(task: String) {
        passcodeView.task.text = task
    }
    
    public func present(error: String) {
        passcodeView.error.text = error.isEmpty ? " " : error
        if !error.isEmpty {
            passcodeView.passcode.shake()
        }
    }
    
    public func present(total: Int, filled: Int) {
        passcodeView.passcode.total = total
        passcodeView.passcode.filled = filled
    }

    public func present(cancel: String) {
        passcodeView.cancel.setTitle(cancel, for: .normal)
    }
}
