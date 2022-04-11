import Foundation
import UIKit
import Model

public protocol AppearanceSettingsUseCaseOutput: AnyObject {
    func present(theme: UIUserInterfaceStyle, legacy: Bool, compact: Bool, reduceAnimation: Bool, legacyDiary: Bool, trash: Bool)
    func presentTrashNotEmpty()
}

public protocol AppearanceSettingsUseCase {
    func eventViewReady()
    func event(legacy: Bool)
    func event(compact: Bool)
    func event(reduceAnimation: Bool)
    func event(legacyDiary: Bool)
    func event(trash: Bool)
    func event(theme: UIUserInterfaceStyle)
}

public final class AppearanceSettingsUseCaseImpl {

    // MARK: - Private

    private let settings: Settings
    private let eventsProvider: EmotionEventsProvider

    private func presentSettings() {
        output.present(
            theme: settings.appearance,
            legacy: settings.useLegacyLayout,
            compact: !settings.useExpandedDiary,
            reduceAnimation: settings.reduceAnimation,
            legacyDiary: settings.useLegacyDiary,
            trash: !settings.eraseImmediately
        )
    }

    // MARK: - Public

    public weak var output: AppearanceSettingsUseCaseOutput!

    public init(settings: Settings, eventsProvider: EmotionEventsProvider) {
        self.settings = settings
        self.eventsProvider = eventsProvider
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

    public func event(trash: Bool) {
        guard trash || eventsProvider.deletedEvents.isEmpty else {
            presentSettings()
            output.presentTrashNotEmpty()
            return
        }
        settings.eraseImmediately = !trash
    }

    public func event(theme: UIUserInterfaceStyle) {
        settings.appearance = theme
        presentSettings()
    }
}
