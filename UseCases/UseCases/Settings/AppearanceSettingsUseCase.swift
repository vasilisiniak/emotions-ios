import Foundation
import Model

public protocol AppearanceSettingsUseCaseOutput: AnyObject {
    func present(legacy: Bool, compact: Bool, reduceAnimation: Bool, legacyDiary: Bool)
}

public protocol AppearanceSettingsUseCase {
    func eventViewReady()
    func event(legacy: Bool)
    func event(compact: Bool)
    func event(reduceAnimation: Bool)
    func event(legacyDiary: Bool)
}

public final class AppearanceSettingsUseCaseImpl {

    // MARK: - Private

    private let settings: Settings

    private func presentSettings() {
        output.present(
            legacy: settings.useLegacyLayout,
            compact: !settings.useExpandedDiary,
            reduceAnimation: settings.reduceAnimation,
            legacyDiary: settings.useLegacyDiary
        )
    }

    // MARK: - Public

    public weak var output: AppearanceSettingsUseCaseOutput!

    public init(settings: Settings) {
        self.settings = settings
    }
}

extension AppearanceSettingsUseCaseImpl: AppearanceSettingsUseCase {
    public func eventViewReady() {
        presentSettings()
    }

    public func event(legacy: Bool) {
        settings.useLegacyLayout = legacy
    }

    public func event(compact: Bool) {
        settings.useExpandedDiary = !compact
    }

    public func event(reduceAnimation: Bool) {
        settings.reduceAnimation = reduceAnimation
    }

    public func event(legacyDiary: Bool) {
        settings.useLegacyDiary = legacyDiary
    }
}
