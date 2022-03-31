import UIKit
import iOSControls

extension EmotionsGroupsViewController {

    final class View: UIView {

        deinit {
            observers?.forEach { NotificationCenter.default.removeObserver($0) }
        }

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private var observers: [NSObjectProtocol]?

        private var expanded: [NSLayoutConstraint] = []
        private var collapsed: [NSLayoutConstraint] = []
        private var labelHeight: [NSLayoutConstraint] = []

        private func addSubviews() {
            addSubview(segmentedControlBackground)
            addSubview(segmentedControl)
            addSubview(label)
            addSubview(tableView)
            addSubview(collectionView)
        }

        private func makeConstraints() {
            segmentedControlBackground.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            tableView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                segmentedControlBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
                segmentedControlBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
                segmentedControlBackground.topAnchor.constraint(equalTo: topAnchor),
                segmentedControlBackground.bottomAnchor.constraint(equalTo: label.topAnchor),

                segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),

                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                label.bottomAnchor.constraint(equalTo: tableView.topAnchor),

                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

                collectionView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
                collectionView.topAnchor.constraint(equalTo: tableView.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
            ])

            labelHeight = [
                label.heightAnchor.constraint(equalToConstant: 0)
            ]

            expanded = [
                segmentedControl.heightAnchor.constraint(equalToConstant: 36),
                segmentedControl.bottomAnchor.constraint(equalTo: segmentedControlBackground.bottomAnchor, constant: -10)
            ]

            collapsed = [
                segmentedControl.heightAnchor.constraint(equalToConstant: 0),
                segmentedControl.bottomAnchor.constraint(equalTo: segmentedControlBackground.bottomAnchor, constant: 0),
                label.heightAnchor.constraint(equalToConstant: 0)
            ]
        }

        // MARK: - Internal

        let segmentedControlBackground = UIView()

        let segmentedControl: UISegmentedControl = create {
            UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).adjustsFontForContentSizeCategory = true
            let font = UIFont.preferredFont(forTextStyle: .callout)
            let boldFont = UIFontMetrics(forTextStyle: .callout).scaledFont(for: .boldSystemFont(ofSize: font.pointSize))
            $0.setTitleTextAttributes([.font : font], for: .normal)
            $0.setTitleTextAttributes([.font : boldFont], for: .selected)
            $0.backgroundColor = .clear
        }

        let label: PaddedLabel = create {
            $0.font = .preferredFont(forTextStyle: .headline)
            $0.adjustsFontForContentSizeCategory = true
            $0.numberOfLines = 0
            $0.textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }

        let tableView: UITableView = create {
            $0.tableFooterView = UIView()
        }

        let layout: LeftAlignedCollectionViewFlowLayout = create {
            $0.sectionInset.left = 10
            $0.sectionInset.right = 10
            $0.sectionInset.top = $0.minimumLineSpacing / 2
            $0.sectionInset.bottom = $0.minimumLineSpacing / 2
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }

        lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)

        let leftSwipeGestureRecognizer: UISwipeGestureRecognizer = {
            let recognizer = UISwipeGestureRecognizer()
            recognizer.direction = .left
            return recognizer
        }()

        let rightSwipeGestureRecognizer: UISwipeGestureRecognizer = {
            let recognizer = UISwipeGestureRecognizer()
            recognizer.direction = .right
            return recognizer
        }()

        func set(expanded flag: Bool) {
            if flag {
                NSLayoutConstraint.deactivate(collapsed)
                NSLayoutConstraint.activate(expanded)
                segmentedControl.alpha = 1
            }
            else {
                NSLayoutConstraint.deactivate(expanded)
                NSLayoutConstraint.activate(collapsed)
                segmentedControl.alpha = 0
            }
        }

        func set(labelCollapsed: Bool) {
            if labelCollapsed {
                NSLayoutConstraint.activate(labelHeight)
            }
            else {
                NSLayoutConstraint.deactivate(labelHeight)
            }
        }

        init() {
            super.init(frame: .zero)
            backgroundColor = .systemBackground
            addGestureRecognizer(leftSwipeGestureRecognizer)
            addGestureRecognizer(rightSwipeGestureRecognizer)
            addSubviews()
            makeConstraints()
            set(expanded: true)

            observers = [
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] in
                    let duration = ($0.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                    let height = ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                    let safe = self?.safeAreaInsets.bottom ?? 0

                    self?.layoutIfNeeded()
                    UIView.animate(withDuration: duration) {
                        self?.layoutMargins.bottom = height - safe
                        self?.layoutIfNeeded()
                    }
                },
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] in
                    let duration = ($0.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
                    self?.layoutIfNeeded()
                    UIView.animate(withDuration: duration) {
                        self?.layoutMargins.bottom = 0
                        self?.layoutIfNeeded()
                    }
                }
            ]
        }
    }
}
