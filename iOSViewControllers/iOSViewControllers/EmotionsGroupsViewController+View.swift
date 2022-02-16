import UIKit
import iOSControls

extension EmotionsGroupsViewController {

    final class View: UIView {

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private func addSubviews() {
            addSubview(segmentedControlBackground)
            addSubview(segmentedControl)
            addSubview(tableView)
            addSubview(collectionView)
        }

        private func makeConstraints() {
            segmentedControlBackground.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            tableView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                segmentedControlBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
                segmentedControlBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
                segmentedControlBackground.topAnchor.constraint(equalTo: topAnchor),
                segmentedControlBackground.bottomAnchor.constraint(equalTo: tableView.topAnchor),

                segmentedControl.heightAnchor.constraint(equalToConstant: 36),
                segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
                segmentedControl.bottomAnchor.constraint(equalTo: segmentedControlBackground.bottomAnchor, constant: -10),

                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

                collectionView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
                collectionView.topAnchor.constraint(equalTo: tableView.topAnchor),
                collectionView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
            ])
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

        init() {
            super.init(frame: .zero)
            backgroundColor = .systemBackground
            addGestureRecognizer(leftSwipeGestureRecognizer)
            addGestureRecognizer(rightSwipeGestureRecognizer)
            addSubviews()
            makeConstraints()
        }
    }
}
