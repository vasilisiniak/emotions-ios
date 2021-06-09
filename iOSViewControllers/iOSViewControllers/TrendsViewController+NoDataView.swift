import UIKit

extension TrendsViewController {
    
    final class NoDataView: UIView {
        
        // MARK: - NSCoding
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Private
        
        private func addSubviews() {
            addSubview(label)
            addSubview(button)
        }
        
        private func makeConstraints() {
            label.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
                label.centerXAnchor.constraint(equalTo: centerXAnchor),
                label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
                label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -30),
                label.centerXAnchor.constraint(equalTo: button.centerXAnchor)
            ])
        }
        
        // MARK: - Internal
        
        let label: UILabel = create {
            $0.font = .preferredFont(forTextStyle: .body)
            $0.adjustsFontForContentSizeCategory = true
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        let button: UIButton = {
            let button = UIButton(type: .system)
            button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
            return button
        }()
        
        init() {
            super.init(frame: .zero)
            backgroundColor = .systemBackground
            addSubviews()
            makeConstraints()
        }
    }
}
