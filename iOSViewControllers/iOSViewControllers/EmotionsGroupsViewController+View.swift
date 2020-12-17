import UIKit
import iOSControls

extension EmotionsGroupsViewController {

    class View: UIView {
        
        // MARK: - NSCoding
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Private
        
        private func addSubviews() {
            addSubview(segmenedControlBackground)
            addSubview(segmentedControl)
            addSubview(label)
            addSubview(tableView)
        }
        
        private func makeConstraints() {
            segmenedControlBackground.translatesAutoresizingMaskIntoConstraints = false
            segmentedControl.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            tableView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                segmenedControlBackground.leadingAnchor.constraint(equalTo: leadingAnchor),
                segmenedControlBackground.trailingAnchor.constraint(equalTo: trailingAnchor),
                segmenedControlBackground.topAnchor.constraint(equalTo: topAnchor),
                segmenedControlBackground.bottomAnchor.constraint(equalTo: label.topAnchor),
                
                segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                segmentedControl.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
                segmentedControl.bottomAnchor.constraint(equalTo: segmenedControlBackground.bottomAnchor, constant: -10),
                
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                label.bottomAnchor.constraint(equalTo: tableView.topAnchor),
                
                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        // MARK: - Internal
        
        let segmenedControlBackground = UIView()
        
        let segmentedControl: UISegmentedControl = create {
            UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).adjustsFontForContentSizeCategory = true
            let font = UIFont.preferredFont(forTextStyle: .callout)
            let boldFont = UIFontMetrics(forTextStyle: .callout).scaledFont(for: UIFont.boldSystemFont(ofSize: font.pointSize))
            $0.setTitleTextAttributes([.font : font], for: .normal)
            $0.setTitleTextAttributes([.font : boldFont], for: .selected)
            $0.backgroundColor = .clear
        }

        let label: PaddedLabel = create {
            $0.font = UIFont.preferredFont(forTextStyle: .headline)
            $0.adjustsFontForContentSizeCategory = true
            $0.numberOfLines = 0
            $0.textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
        let tableView = UITableView()

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
