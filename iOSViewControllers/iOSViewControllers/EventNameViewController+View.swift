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
            addSubview(textView)
            addSubview(label)
        }
        
        private func makeConstraints() {
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            textView.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
                backgroundView.topAnchor.constraint(equalTo: topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
                textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
                textView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 9),
                textView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -9),
                
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        }
        
        // MARK: - Internal
        
        let backgroundView = UIView()
        
        let textView: ExpandableTextView = create {
            $0.adjustsFontForContentSizeCategory = true
            $0.font = .preferredFont(forTextStyle: .body)
            $0.backgroundColor = UIColor.white.withAlphaComponent(0.5)
            if let font = $0.font {
                $0.heightConstraints = (min: font.lineHeight + 18, max: font.lineHeight * 10)
            }
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
