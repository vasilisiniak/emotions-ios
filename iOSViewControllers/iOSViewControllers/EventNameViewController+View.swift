import UIKit
import iOSControls

extension EventNameViewController {
    
    final class View: UIView {
        
        // MARK: - NSCoding
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Private
        
        private func addSubviews() {
            addSubview(backgroundView)
            addSubview(textField)
            addSubview(label)
        }
        
        private func makeConstraints() {
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            textField.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
                backgroundView.topAnchor.constraint(equalTo: topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                textField.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 9),
                textField.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -9),
                
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
        
        // MARK: - Internal
        
        let backgroundView = UIView()
        
        let textField: UITextField = create {
            $0.borderStyle = .roundedRect
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .body)
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
        
        let label: PaddedLabel = create {
            $0.font = .preferredFont(forTextStyle: .headline)
            $0.adjustsFontForContentSizeCategory = true
            $0.numberOfLines = 0
            $0.textInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
        init() {
            super.init(frame: .zero)
            backgroundColor = .systemBackground
            addSubviews()
            makeConstraints()
        }
    }
}
