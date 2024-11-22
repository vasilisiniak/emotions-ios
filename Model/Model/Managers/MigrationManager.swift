import Foundation

public protocol MigrationManager {
    func migrate()
}

public final class MigrationManagerImpl {

    private enum Constants {
        static let VersionKey = "Model.MigrationManagerImpl.VersionKey"
    }

    // MARK: - Private

    private let eventsProvider: EmotionEventsProvider
    private let settings: Settings
    private let lockStorage: LockManagerStorage

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
        "1.0": migrate_1_0_to_1_7,
        "1.7": migrate_1_7_to_1_32
    ]

    private func migrate_1_0_to_1_7() -> String {
        eventsProvider.events
            .filter { $0.color == "6bb6bc" }
            .map { EmotionEvent(date: $0.date, name: $0.name, details: $0.details, emotions: $0.emotions, color: "6b3074") }
            .forEach { eventsProvider.update(event: $0) }
        return "1.7"
    }

    private func migrate_1_7_to_1_32() -> String {
        if settings.useFaceId {
            if !lockStorage.setLockSource(source: LockManagerSource.system.rawValue) {
                print("Error while setting system lock source while migrating from 1.7 to 1.32")
            }
        }
        return "1.32"
    }

    // MARK: - Public

    public init(eventsProvider: EmotionEventsProvider, settings: Settings, lockStorage: LockManagerStorage) {
        self.eventsProvider = eventsProvider
        self.settings = settings
        self.lockStorage = lockStorage
    }
}

extension MigrationManagerImpl: MigrationManager {
    public func migrate() {
        repeat { } while migrateIfNeeded()
    }
}
