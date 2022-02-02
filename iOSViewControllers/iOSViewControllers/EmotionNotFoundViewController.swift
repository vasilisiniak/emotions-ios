import UIKit
import Presenters

public final class EmotionNotFoundViewController: UIViewController {

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        presenter.eventViewReady()
    }

    public override func loadView() {
        view = emotionNotFoundView
    }

    // MARK: - NSCoding

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private lazy var emotionNotFoundView: View = Self.create {
        $0.button.addAction(UIAction { [presenter] _ in presenter?.eventSuggest() }, for: .touchUpInside)
    }

    // MARK: - Public

    public var presenter: EmotionNotFoundPresenter!

    public init() {
        super.init(nibName: nil, bundle: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [presenter] _ in presenter?.eventClose() })
    }
}

extension EmotionNotFoundViewController: EmotionNotFoundPresenterOutput {
    public func showEmailAlert(message: String, okButton: String, infoButton: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: okButton, style: .default))
        alert.addAction(UIAlertAction(title: infoButton, style: .default, handler: { [weak self] _ in
            self?.presenter.eventEmailInfo()
        }))
        present(alert, animated: true)
    }

    public func show(info: String) {
        emotionNotFoundView.label.text = info
    }

    public func show(button: String) {
        emotionNotFoundView.button.setTitle(button, for: .normal)
    }
}
