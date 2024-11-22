import Foundation
import UIKit
import Utils
import Model

public enum PrivacySettingsUseCaseObjects {

    public enum LockMode {
        case system
        case passcode
    }
}

public protocol PrivacySettingsUseCaseOutput: AnyObject {
    func present(url: String)
    func present(protect: Bool, faceId: Bool)
    func presentFaceIdError()
}

public protocol PrivacySettingsUseCase {
    func eventViewReady()
    func eventFaceIdInfo()
    func event(protect: Bool, info: String)
    func eventEnableLock(mode: PrivacySettingsUseCaseObjects.LockMode, info: String)
    func eventDisableLock(info: String)
}

public final class PrivacySettingsUseCaseImpl {

    // MARK: - Private

    private let settings: Settings
    private let analytics: AnalyticsManager
    private let lock: LockManager
    private let faceIdInfo: String

    private func handleLockCompletion(available: Bool, passed: Bool, operation: @escaping () -> ()) {
        DispatchQueue.main.async { [weak self] in
            if !available {
                self?.output.presentFaceIdError()
            }
            if passed {
                operation()
            }
            self?.presentSettings()
        }
    }

    private func presentSettings() {
        output.present(protect: settings.protectSensitiveData, faceId: settings.useFaceId)
    }

    // MARK: - Public

    public weak var output: PrivacySettingsUseCaseOutput!

    public init(settings: Settings, analytics: AnalyticsManager, lock: LockManager, faceIdInfo: String) {
        self.settings = settings
        self.analytics = analytics
        self.lock = lock
        self.faceIdInfo = faceIdInfo
    }
}

extension PrivacySettingsUseCaseImpl: PrivacySettingsUseCase {

    public func eventEnableLock(mode: PrivacySettingsUseCaseObjects.LockMode, info: String) {
        let source: LockManagerSource

        switch mode {
        case .passcode: source = .passcode
        case .system: source = .system
        }

        lock.set(source: source, info: info) { [settings, weak self] available, passed in
            self?.handleLockCompletion(available: available, passed: passed) {
                settings.protectSensitiveData = true
                settings.useFaceId = true
            }
        }
    }

    public func eventDisableLock(info: String) {
        lock.unset(info: info) { [settings, weak self] available, passed in
            self?.handleLockCompletion(available: available, passed: passed) {
                settings.protectSensitiveData = true
                settings.useFaceId = false
            }
        }
    }

    public func event(protect: Bool, info: String) {
        if !protect && settings.useFaceId {
            lock.unset(info: info) { [settings, weak self] available, passed in
                self?.handleLockCompletion(available: available, passed: passed) {
                    settings.protectSensitiveData = false
                    settings.useFaceId = false
                }
            }
        } else {
            settings.protectSensitiveData = protect
            presentSettings()
        }
    }

    public func eventViewReady() {
        presentSettings()
    }

    public func eventFaceIdInfo() {
        output.present(url: faceIdInfo)
    }
}
