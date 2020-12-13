import UIKit
import Presenters

public class EventNameViewController: UIViewController {
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.eventViewReady()
    }
    
    public override func loadView() {
        view = eventNameView
    }
    
    // MARK: - Private
    
    private let eventNameView = EventNameView()
    
    private func onBack() {
        presenter.eventBackTap()
    }
    
    // MARK: - Public
    
    public var presenter: EventNamePresenter!
}

extension EventNameViewController: EventNamePresenterOutput {
    public func show(title: String) {
        self.title = title
    }
    
    public func show(backButton: String) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: backButton, handler: onBack)
    }
    
    public func show(placeholder: String) {
        eventNameView.textField.placeholder = placeholder
    }
    
    public func show(selectedEmotions: String) {
        eventNameView.label.text = selectedEmotions
    }
    
    public func showKeyboard() {
        eventNameView.textField.becomeFirstResponder()
    }
}
