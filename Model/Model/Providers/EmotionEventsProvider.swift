import Foundation
import Storage

public typealias EmotionEventsProviderListener = () -> ()

public protocol EmotionEventsProvider {
    var events: [EmotionEvent] { get }
    var deletedEvents: [EmotionEvent] { get }
    func log(event: EmotionEvent)
    func delete(event: EmotionEvent)
    func erase(event: EmotionEvent)
    func eraseExpired()
    func restore(event: EmotionEvent)
    func update(event: EmotionEvent, for: Date)
    func add(listener: @escaping EmotionEventsProviderListener)
}

public extension EmotionEventsProvider {
    func update(event: EmotionEvent) {
        update(event: event, for: event.date)
    }

    func eraseAll() {
        while let event = events.first {
            erase(event: event)
        }
    }
}

fileprivate extension EmotionEvent {
    init(entity: StorageEntity) {
        date = entity.value(forKey: "date") as! Date
        name = entity.value(forKey: "name") as! String
        details = entity.value(forKey: "details") as? String
        emotions = entity.value(forKey: "emotions") as! String
        color = entity.value(forKey: "color") as! String
        deleted = entity.value(forKey: "deletedDate") as? Date
    }

    func write(to entity: StorageEntity) {
        entity.setValue(date, forKey: "date")
        entity.setValue(name, forKey: "name")
        entity.setValue(details, forKey: "details")
        entity.setValue(emotions, forKey: "emotions")
        entity.setValue(color, forKey: "color")
        entity.setValue(deleted, forKey: "deletedDate")
    }
}

public final class EmotionEventsProviderImpl<EmotionEventEntity: StorageEntity> {

    // MARK: - Private

    private let expirationInterval: TimeInterval = 3 * 24 * 60 * 60
    private let storage: Storage

    // MARK: - Public

    public init(storage: Storage) {
        self.storage = storage
    }
}

extension EmotionEventsProviderImpl: EmotionEventsProvider {
    public var events: [EmotionEvent] {
        let entities: [EmotionEventEntity] = storage.get()
        return entities
            .map(EmotionEvent.init)
            .filter { $0.deleted == nil }
    }

    public var deletedEvents: [EmotionEvent] {
        let entities: [EmotionEventEntity] = storage.get()
        return entities
            .map(EmotionEvent.init)
            .filter { $0.deleted != nil }
    }

    public func delete(event: EmotionEvent) {
        let entities: [EmotionEventEntity] = storage.get()
        let entity = entities.first { $0.value(forKey: "date") as! Date == event.date }!
        entity.setValue(Date(), forKey: "deletedDate")
        storage.save(entity: entity)
    }

    public func erase(event: EmotionEvent) {
        let entities: [EmotionEventEntity] = storage.get()
        let entity = entities.first { $0.value(forKey: "date") as! Date == event.date }!
        storage.delete(entity: entity)
    }

    public func restore(event: EmotionEvent) {
        let entities: [EmotionEventEntity] = storage.get()
        let entity = entities.first { $0.value(forKey: "date") as! Date == event.date }!
        entity.setValue(nil, forKey: "deletedDate")
        storage.save(entity: entity)
    }

    public func add(listener: @escaping EmotionEventsProviderListener) {
        storage.add(listener: listener)
    }

    public func log(event: EmotionEvent) {
        let entity: EmotionEventEntity = storage.create()
        event.write(to: entity)
        storage.add(entity: entity)
    }

    public func update(event: EmotionEvent, for date: Date) {
        let entities: [EmotionEventEntity] = storage.get()
        let entity = entities.first { $0.value(forKey: "date") as! Date == date }!
        event.write(to: entity)
        storage.save(entity: entity)
    }

    public func eraseExpired() {
        let expiredDate = Date().advanced(by: -expirationInterval)
        let expired = deletedEvents.filter { $0.deleted! <= expiredDate }
        expired.forEach { erase(event: $0) }
    }
}
