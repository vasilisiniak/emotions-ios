import MetricKit

public protocol MetricsManager {
    func start()
}

public final class MetricsManagerImpl: NSObject {

    // MARK: - Public

    public override init() {}
}

extension MetricsManagerImpl: MetricsManager {
    public func start() {
        MXMetricManager.shared.add(self)
    }
}

extension MetricsManagerImpl: MXMetricManagerSubscriber {
    #if DEBUG
        public func didReceive(_ payloads: [MXMetricPayload]) {
            print("Did receive MetricKit metric payloads: \(payloads)")
        }
        public func didReceive(_ payloads: [MXDiagnosticPayload]) {
            print("Did receive MetricKit diagnostic payloads: \(payloads)")
        }
    #endif
}
