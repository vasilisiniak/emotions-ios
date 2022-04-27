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
            addSubview(histogram)
        }

        private func makeConstraints() {
            gradientView.translatesAutoresizingMaskIntoConstraints = false
            noDataView.translatesAutoresizingMaskIntoConstraints = false
            dateRangePicker.translatesAutoresizingMaskIntoConstraints = false
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

                histogram.leadingAnchor.constraint(equalTo: leadingAnchor),
                histogram.trailingAnchor.constraint(equalTo: trailingAnchor),
                histogram.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
            ])
        }

        // MARK: - Internal

        let gradientView = GradientView()
        let noDataView = NoDataView()
        let dateRangePicker = DateRangePicker()
        let histogram = Histogram()

        init() {
            super.init(frame: .zero)
            backgroundColor = .systemBackground
            addSubviews()
            makeConstraints()
        }
    }
}
