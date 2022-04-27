import UIKit
import iOSControls

extension TrendsViewController {

    final class View: UIView {

        // MARK: - NSCoding

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: - Private

        private func addSubviews() {
            addSubview(gradientView)
            addSubview(noDataView)
            addSubview(dateRangePicker)
            addSubview(blur)
            addSubview(histogram)
        }

        private func makeConstraints() {
            gradientView.translatesAutoresizingMaskIntoConstraints = false
            noDataView.translatesAutoresizingMaskIntoConstraints = false
            dateRangePicker.translatesAutoresizingMaskIntoConstraints = false
            blur.translatesAutoresizingMaskIntoConstraints = false
            histogram.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
                gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
                gradientView.topAnchor.constraint(equalTo: topAnchor),
                gradientView.bottomAnchor.constraint(equalTo: bottomAnchor),

                dateRangePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
                dateRangePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
                dateRangePicker.topAnchor.constraint(equalTo: topAnchor),

                noDataView.leadingAnchor.constraint(equalTo: leadingAnchor),
                noDataView.trailingAnchor.constraint(equalTo: trailingAnchor),
                noDataView.topAnchor.constraint(equalTo: topAnchor),
                noDataView.bottomAnchor.constraint(equalTo: bottomAnchor),

                blur.leadingAnchor.constraint(equalTo: leadingAnchor),
                blur.trailingAnchor.constraint(equalTo: trailingAnchor),
                blur.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),

                histogram.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
                histogram.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
                histogram.topAnchor.constraint(equalTo: blur.topAnchor, constant: blur.offset),
                histogram.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            ])
        }

        // MARK: - Internal

        let gradientView = GradientView()
        let noDataView = NoDataView()
        let dateRangePicker = DateRangePicker()
        let histogram = Histogram()

        let blur: GradientedTop<UIVisualEffectView> = create {
            $0.view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        }

        init() {
            super.init(frame: .zero)
            backgroundColor = .systemBackground
            addSubviews()
            makeConstraints()
        }
    }
}
