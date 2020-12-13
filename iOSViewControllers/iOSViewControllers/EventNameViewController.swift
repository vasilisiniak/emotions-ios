import Foundation
import UIKit
import Presenters

public class EventNameViewController: UIViewController {
    
    // MARK: - UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.eventViewReady()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.eventViewDidAppear()
    }
    
    public override func loadView() {
        view = eventNameView
    }
    
    // MARK: - Private
    
    private lazy var eventNameView: EventNameView = EventNameViewController.create {
        let name = UITextField.textDidChangeNotification
        NotificationCenter.default.addObserver(forName: name, object: $0.textField, queue: .main, using: onTextChange)
    }
    
    private func onBack() {
        presenter.eventBackTap()
    }
    
    private func onAdd() {
        presenter.eventAddTap()
    }
    
    private func onTextChange(_: Notification) {
        presenter.event(descriptionChanged: eventNameView.textField.text)
    }
    
    // MARK: - Public
    
    public var presenter: EventNamePresenter!
}

extension EventNameViewController: EventNamePresenterOutput {
    public func show(addButtonEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = addButtonEnabled
    }
    
    public func show(title: String) {
        self.title = title
    }
    
    public func show(backButton: String) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: backButton, handler: onBack)
    }
    
    public func show(addButton: String) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: addButton, handler: onAdd)
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
