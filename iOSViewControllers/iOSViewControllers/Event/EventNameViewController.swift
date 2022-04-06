import Foundation
import UIKit
import Presenters

fileprivate extension UIColor {
    static var placeholder: UIColor {
        .label.withAlphaComponent(0.55)
    }
}

public final class EventNameViewController: UIViewController {

    deinit {
        observers?.forEach { NotificationCenter.default.removeObserver($0) }
    }

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

    private var observers: [AnyObject]?

    private var namePlaceholder: String? {
        didSet { name = name }
    }

    private var detailsPlaceholder: String? {
        didSet { details = details }
    }

    private var name: String? {
        get {
            guard eventNameView.name.textColor != .placeholder else { return nil }
            return eventNameView.name.text
        }
        set {
            eventNameView.name.text = (newValue?.isEmpty == false) ? newValue: namePlaceholder
            eventNameView.name.textColor = (newValue?.isEmpty == false) ? .label : .placeholder
        }
    }

    private var details: String? {
        get {
            guard eventNameView.details.textColor != .placeholder else { return nil }
            return eventNameView.details.text
        }
        set {
            eventNameView.details.text = (newValue?.isEmpty == false) ? newValue : detailsPlaceholder
            eventNameView.details.textColor = (newValue?.isEmpty == false) ? .label : .placeholder
        }
    }

    private lazy var eventNameView: View = EventNameViewController.create {
        $0.name.delegate = self
        $0.details.delegate = self

        $0.name.pasteDelegate = self
        $0.details.pasteDelegate = self

        let name = UITextView.textDidChangeNotification
        observers = [
            NotificationCenter.default.addObserver(forName: name, object: $0.name, queue: .main) { [weak self] _ in self?.onNameChange() },
            NotificationCenter.default.addObserver(forName: name, object: $0.details, queue: .main) { [weak self] _ in self?.onDetailsChange() }
        ]

        $0.date.addAction(UIAction { [weak self] _ in self?.onDateChanged() }, for: .valueChanged)
    }

    private func onBack() {
        presenter.eventCancelTap()
    }

    private func onAdd() {
        presenter.eventAddTap()
    }

    private func onDateChanged() {
        presenter.event(dateChanged: eventNameView.date.date)
    }

    private func onNameChange() {
        presenter.event(nameChanged: name)
    }

    private func onDetailsChange() {
        presenter.event(detailsChanged: details)
    }

    // MARK: - Public

    public var presenter: EventNamePresenter!
}

extension EventNameViewController: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .placeholder else { return }

        textView.text = nil
        textView.textColor = .label
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        guard textView.text.isEmpty else { return }

        switch textView {
        case eventNameView.name: name = textView.text
        case eventNameView.details: details = textView.text
        default: fatalError()
        }
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView.textContainer.maximumNumberOfLines == 2 else { return true }
        guard let oldText = textView.text, let newRange = Range(range, in: oldText) else { return true }

        let newText = oldText.replacingCharacters(in: newRange, with: text)
        defer {
            if newText.hasSuffix("\n") {
                eventNameView.details.becomeFirstResponder()
                eventNameView.details.resignFirstResponder()
                eventNameView.details.becomeFirstResponder()
            }
        }

        return !newText.contains("\n")
    }
}

extension EventNameViewController: UITextPasteDelegate {
    public func textPasteConfigurationSupporting(
        _ textPasteConfigurationSupporting: UITextPasteConfigurationSupporting,
        performPasteOf attributedString: NSAttributedString,
        to textRange: UITextRange
    ) -> UITextRange {
        let textView = (textPasteConfigurationSupporting as? UITextView)
        textView?.replace(textRange, withText: attributedString.string)
        return textRange
    }
}

extension EventNameViewController: EventNamePresenterOutput {
    public func show(color: UIColor) {
        eventNameView.backgroundView.backgroundColor = color.withAlphaComponent(0.2)
    }

    public func show(addButtonEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = addButtonEnabled
    }

    public func show(title: String, name: String, details: String) {
        self.title = title
        namePlaceholder = name
        detailsPlaceholder = details
    }

    public func show(backButton: String) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: backButton) { [weak self] in self?.onBack()}
    }

    public func show(addButton: String) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: addButton) { [weak self] in self?.onAdd()}
    }

    public func show(selectedEmotions: [EventNamePresenterObjects.Emotion]) {
        selectedEmotions
            .map { Bubble.create($0.name, $0.color) }
            .forEach { eventNameView.emotions.add(view: $0) }
    }

    public func show(date: Date, name: String, details: String?) {
        eventNameView.date.date = date
        self.name = name
        self.details = details
    }

    public func showKeyboard() {
        eventNameView.name.becomeFirstResponder()
    }
}
