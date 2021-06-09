import UIKit
import Utils

public final class DateRangePicker: UIControl {

    // MARK: - NSCoding

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private let dashLabel: UILabel = create {
        $0.text = "—"
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
    }

    private let stackView = UIStackView()

    private let resetFromDateButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(), target: nil, action: nil)
        button.setTitle("✖", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 0)
        return button
    }()

    private let resetToDateButton: UIButton = {
        let button = UIButton.systemButton(with: UIImage(), target: nil, action: nil)
        button.setTitle("✖", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 20)
        return button
    }()

    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(stackView)

        stackView.insertArrangedSubview(resetToDateButton, at: 0)
        stackView.insertArrangedSubview(toDatePicker, at: 0)
        stackView.insertArrangedSubview(dashLabel, at: 0)
        stackView.insertArrangedSubview(fromDatePicker, at: 0)
        stackView.insertArrangedSubview(resetFromDateButton, at: 0)

        stackView.setCustomSpacing(10, after: dashLabel)
        stackView.setCustomSpacing(10, after: fromDatePicker)
    }

    private func makeConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Public

    public var range: (min: Date?, max: Date?) = (min: nil, max: nil) {
        didSet {
            fromDatePicker.minimumDate = range.min
            fromDatePicker.maximumDate = range.max
            fromDatePicker.date = selectedRange.min ?? range.min ?? Date()
            toDatePicker.minimumDate = range.min
            toDatePicker.maximumDate = range.max
            toDatePicker.date = selectedRange.max ?? range.max ?? Date()
        }
    }

    public var selectedRange: (min: Date?, max: Date?) = (min: nil, max: nil) {
        didSet {
            fromDatePicker.date = selectedRange.min ?? range.min ?? Date()
            toDatePicker.date = selectedRange.max ?? range.max ?? Date()

            resetFromDateButton.isHidden = (selectedRange.min == nil)
            resetToDateButton.isHidden = (selectedRange.max == nil)
        }
    }

    public let titleLabel: UILabel = create {
        $0.textAlignment = .center
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
    }

    public let fromDatePicker: UIDatePicker = create {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .compact
    }

    public let toDatePicker: UIDatePicker = create {
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .compact
    }

    public init() {
        super.init(frame: .zero)
        backgroundColor = .systemBackground

        fromDatePicker.addAction(UIAction { [weak self] _ in
            self?.selectedRange.min = self?.fromDatePicker.date
            self?.sendActions(for: .valueChanged)
        }, for: .valueChanged)

        toDatePicker.addAction(UIAction { [weak self] _ in
            self?.selectedRange.max = self?.toDatePicker.date
            self?.sendActions(for: .valueChanged)
        }, for: .valueChanged)

        resetFromDateButton.addAction(UIAction { [weak self] _ in
            self?.selectedRange.min = nil
            self?.sendActions(for: .valueChanged)
        }, for: .touchUpInside)

        resetToDateButton.addAction(UIAction { [weak self] _ in
            self?.selectedRange.max = nil
            self?.sendActions(for: .valueChanged)
        }, for: .touchUpInside)

        addSubviews()
        makeConstraints()
    }
}
