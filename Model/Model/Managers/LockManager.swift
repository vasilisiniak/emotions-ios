import LocalAuthentication

public enum LockManagerSource: String {
    case system
    case passcode
}

public protocol LockManager {
    func set(source: LockManagerSource, info: String, completion: @escaping (_ available: Bool, _ passed: Bool) -> ())
    func unset(info: String, completion: @escaping (_ available: Bool, _ passed: Bool) -> ())
    func evaluate(info: String, completion: @escaping (_ available: Bool, _ passed: Bool) -> ())
}

public protocol LockManagerUI: AnyObject {
    func displaySetPasscode(info: String, completion: @escaping (_ success: Bool) -> ())
    func displayCheckPasscode(info: String, completion: @escaping (_ success: Bool) -> ())
}

public protocol PasscodeManager {
    var length: Int { get }
    func set(passcode: String) -> Bool
    func check(passcode: String) -> Bool
}

public protocol LockManagerStorage {
    func getLockSource() -> String?
    func setLockSource(source: String) -> Bool
    func clearLockSource() -> Bool

    func getPasscode() -> String?
    func savePasscode(_ passcode: String) -> Bool
    func clearPasscode() -> Bool
}

public final class LockManagerImpl {

    private enum Task {
        case setPasscode
        case unsetPasscode
        case checkPasscode
    }

    // MARK: - Private

    private let storage: LockManagerStorage
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

    private var source: LockManagerSource {
        guard let sourceStr = storage.getLockSource() else {
            print("Error while getting lock source")
            return .system
        }
        guard let sourceVal = LockManagerSource(rawValue: sourceStr) else {
            print("Error while mapping lock source from \(sourceStr) to enum")
            return .system
        }
        return sourceVal
    }

    private func evaluatePasscode(task: Task, info: String, completion: @escaping (_ passed: Bool) -> ()) {
        switch task {
        case .setPasscode:
            uiManager.displaySetPasscode(info: info, completion: completion)
        case .checkPasscode:
            uiManager.displayCheckPasscode(info: info, completion: completion)
        case .unsetPasscode:
            uiManager.displayCheckPasscode(info: info) { [storage] passed in
                if passed {
                    if !storage.clearPasscode() {
                        print("Error while clearing passcode")
                    }
                    if !storage.clearLockSource() {
                        print("Error while clearing lock source")
                    }
                }
                completion(passed)
            }
        }
    }

    private func evaluateSystem(info: String, completion: @escaping (_ available: Bool, _ passed: Bool) -> ()) {
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

    // MARK: - Public

    public weak var uiManager: LockManagerUI!
    public let length = 4

    public init(storage: LockManagerStorage) {
        self.storage = storage
    }
}

extension LockManagerImpl: LockManager {

    public func evaluate(info: String, completion: @escaping (_ available: Bool, _ passed: Bool) -> ()) {
        switch source {
        case .system:
            evaluateSystem(info: info, completion: completion)
        case .passcode:
            evaluatePasscode(task: .checkPasscode, info: info) { passed in completion(true, passed) }
        }
    }

    public func set(source: LockManagerSource, info: String, completion: @escaping (_ available: Bool, _ passed: Bool) -> ()) {

        let handler = { [storage] (available: Bool, passed: Bool) in
            let isSet = passed && storage.setLockSource(source: source.rawValue)
            completion(available, isSet)
        }

        switch source {
        case .system:
            evaluateSystem(info: info, completion: handler)
        case .passcode:
            evaluatePasscode(task: .setPasscode, info: info) { passed in handler(true, passed) }
        }
    }

    public func unset(info: String, completion: @escaping (_ available: Bool, _ passed: Bool) -> ()) {

        switch source {
        case .system:
            evaluateSystem(info: info) { [storage] available, passed in
                if passed {
                    if !storage.clearLockSource() {
                        print("Error while clearing lock source")
                    }
                }
                completion(available, passed)
            }
        case .passcode:
            evaluatePasscode(task: .unsetPasscode, info: info) { passed in completion(true, passed) }
        }
    }
}

extension LockManagerImpl: PasscodeManager {

    public func set(passcode: String) -> Bool {
        return storage.savePasscode(passcode)
    }

    public func check(passcode: String) -> Bool {
        return storage.getPasscode() == passcode
    }
}
