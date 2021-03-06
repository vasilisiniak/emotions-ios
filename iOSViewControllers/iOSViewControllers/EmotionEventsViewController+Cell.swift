import UIKit

extension EmotionEventsViewController {
    
    final class Cell: UITableViewCell {
        
        // MARK: - UITableViewCell
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: Cell.reuseIdentifier)
            separatorInset = .zero
            selectionStyle = .none
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
            contentView.addSubview(shareButton)
            contentView.addSubview(emotionsLabel)
        }
        
        private func makeConstraints() {
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            shareButton.translatesAutoresizingMaskIntoConstraints = false
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
                timeLabel.leadingAnchor.constraint(equalTo: emotionsLabel.trailingAnchor),

                shareButton.rightAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 2),
                shareButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
                
                emotionsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
            ])
        }
        
        // MARK: - Internal
        
        static let reuseIdentifier = String(describing: UITableViewCell.self)
        
        let nameLabel: UILabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .headline)
            $0.numberOfLines = 0
        }
        
        let timeLabel: UILabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .subheadline)
        }

        let shareButton: UIButton = create {
            let image = UIImage(named: "ShareIcon", in: Bundle(for: Cell.self), with: nil)
            $0.setImage(image, for: .normal)
        }
        
        let emotionsLabel: UILabel = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .body)
            $0.numberOfLines = 0
        }
    }
}
