import UIKit

extension EmotionEventsViewController {
    
    final class Cell: UITableViewCell {
        
        // MARK: - UITableViewCell
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: Cell.reuseIdentifier)
            separatorInset = .zero
            addSubviews()
            makeConstraints()
        }
        
        // MARK: - NSCoding
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Private
        
        private func addSubviews() {
            contentView.addSubview(nameLabel)
            contentView.addSubview(timeLabel)
            contentView.addSubview(emotionsLabel)
        }
        
        private func makeConstraints() {
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            emotionsLabel.translatesAutoresizingMaskIntoConstraints = false
            
            timeLabel.setContentHuggingPriority(.required, for: .horizontal)
            timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            NSLayoutConstraint.activate([
                nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
                nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor),
                nameLabel.topAnchor.constraint(equalTo: timeLabel.topAnchor),
                nameLabel.bottomAnchor.constraint(equalTo: emotionsLabel.topAnchor, constant: -10),
                nameLabel.leadingAnchor.constraint(equalTo: emotionsLabel.leadingAnchor),
                
                timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
                timeLabel.trailingAnchor.constraint(equalTo: emotionsLabel.trailingAnchor),
                
                emotionsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
            ])
        }
        
        // MARK: - Internal
        
        static let reuseIdentifier = String(describing: UITableViewCell.self)
        
        let nameLabel: UILabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = UIFont.preferredFont(forTextStyle: .headline)
            $0.numberOfLines = 0
        }
        
        let timeLabel: UILabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = UIFont.preferredFont(forTextStyle: .subheadline)
        }
        
        let emotionsLabel: UILabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = UIFont.preferredFont(forTextStyle: .body)
            $0.numberOfLines = 0
        }
    }
}
