import Foundation
import WidgetKit

public protocol MigrationManager {
    func migrate()
}

public final class MigrationManagerImpl {

    private enum Constants {
        fileprivate static let VersionKey = "Model.MigrationManagerImpl.VersionKey"
    }

    // MARK: - Private

    private let eventsProvider: EmotionEventsProvider

    private var lastMigratedVersion: String? {
        get { UserDefaults.standard.string(forKey: Constants.VersionKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: Constants.VersionKey); UserDefaults.standard.synchronize() }
    }

    private func migrateIfNeeded() -> Bool {
        guard let migration = migrations[lastMigratedVersion ?? "1.0"] else { return false }
        lastMigratedVersion = migration()
        return true
    }

    private lazy var migrations = [
        "1.0" : migrate_1_0_to_1_7
    ]

    private func migrate_1_0_to_1_7() -> String {
        eventsProvider.events
            .filter { $0.color == "6bb6bc" }
            .map { EmotionEvent(date: $0.date, name: $0.name, details: $0.details, emotions: $0.emotions, color: "6b3074") }
            .forEach { eventsProvider.update(event: $0) }
        WidgetCenter.shared.reloadAllTimelines()
        return "1.7"
    }

    // MARK: - Public

    public init(eventsProvider: EmotionEventsProvider) {
        self.eventsProvider = eventsProvider
    }
}

extension MigrationManagerImpl: MigrationManager {
    public func migrate() {
        repeat { } while migrateIfNeeded()
    }
}
