import Foundation
import UIKit
import Presenters

public final class EventNameViewController: UIViewController {
    
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
    
    private lazy var eventNameView: View = EventNameViewController.create {
        let name = UITextView.textDidChangeNotification
        NotificationCenter.default.addObserver(forName: name, object: $0.textView, queue: .main, using: onTextChange)
    }
    
    private func onBack() {
        presenter.eventBackTap()
    }
    
    private func onAdd() {
        presenter.eventAddTap()
    }
    
    private func onTextChange(_: Notification) {
        presenter.event(descriptionChanged: eventNameView.textView.text)
    }
    
    // MARK: - Public
    
    public var presenter: EventNamePresenter!
}

extension EventNameViewController: EventNamePresenterOutput {
    public func show(color: UIColor) {
        eventNameView.label.backgroundColor = color.withAlphaComponent(0.2)
        eventNameView.backgroundView.backgroundColor = color.withAlphaComponent(0.2)
    }
    
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
    
    public func show(selectedEmotions: String) {
        eventNameView.label.text = selectedEmotions
    }
    
    public func showKeyboard() {
        eventNameView.textView.becomeFirstResponder()
    }
}
