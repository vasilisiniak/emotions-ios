import Foundation
import UIKit
import Utils
import Model

public protocol PrivacySettingsUseCaseOutput: AnyObject {
    func present(url: String)
    func present(protect: Bool, faceId: Bool)
    func presentFaceIdError()
}

public protocol PrivacySettingsUseCase {
    func eventViewReady()
    func eventFaceIdInfo()
    func event(protect: Bool, info: String)
    func event(faceId: Bool, info: String)
}

public final class PrivacySettingsUseCaseImpl {

    // MARK: - Private

    private let settings: Settings
    private let analytics: AnalyticsManager
    private let lock: LockManager
    private let faceIdInfo: String

    private func evaluate(info: String, operation: @escaping () -> ()) {
        lock.evaluate(info: info) { [weak self] available, passed in
            DispatchQueue.main.async {
                if !available {
                    self?.output.presentFaceIdError()
                }
                if passed {
                    operation()
                }
                self?.presentSettings()
            }
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
    public func event(protect: Bool, info: String) {
        if !protect && settings.useFaceId {
            evaluate(info: info) { [settings] in
                settings.protectSensitiveData = false
                settings.useFaceId = false
            }
        } else {
            settings.protectSensitiveData = protect
            presentSettings()
        }
    }

    public func event(faceId: Bool, info: String) {
        evaluate(info: info) { [settings] in
            settings.protectSensitiveData = true
            settings.useFaceId = faceId
        }
    }

    public func eventViewReady() {
        presentSettings()
    }

    public func eventFaceIdInfo() {
        output.present(url: faceIdInfo)
    }
}
