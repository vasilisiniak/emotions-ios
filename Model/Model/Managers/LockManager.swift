import LocalAuthentication

public protocol LockManager {
    func evaluate(info: String, completion: @escaping (_ available: Bool, _ passed: Bool) -> ())
}

public final class LockManagerImpl {

    // MARK: - Private

    private var queue = [(Bool, Bool) -> ()]()
    private let lock = NSLock()

    private var available: Bool {
        supports(.deviceOwnerAuthentication)
    }

    private var policy: LAPolicy {
        supports(.deviceOwnerAuthenticationWithBiometrics) ? .deviceOwnerAuthenticationWithBiometrics : .deviceOwnerAuthentication
    }

    private func supports(_ policy: LAPolicy) -> Bool {
        var error: NSError?
        let available = LAContext().canEvaluatePolicy(policy, error: &error)
        if let error = error {
            print("Error while checking policy \(policy) availability: \(error)")
        }
        return available
    }

    // MARK: - Public

    public init() {}
}

extension LockManagerImpl: LockManager {
    public func evaluate(info: String, completion: @escaping (_ available: Bool, _ passed: Bool) -> ()) {
        guard available else {
            completion(false, false)
            return
        }

        lock.lock()
        defer { lock.unlock() }

        queue.append(completion)
        guard queue.count == 1 else {
            return
        }

        LAContext().evaluatePolicy(policy, localizedReason: info) { [weak self, policy] success, error in
            if let error = error {
                print("Error while evaluating policy \(policy): \(error)")
            }
            self?.lock.lock()
            self?.queue.forEach { $0(true, success) }
            self?.queue.removeAll()
            self?.lock.unlock()
        }
    }
}
