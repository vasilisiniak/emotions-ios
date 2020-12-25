import Foundation
import Storage

public typealias EmotionEventsProviderListener = () -> ()

public protocol EmotionEventsProvider {
    var events: [EmotionEvent] { get }
    func log(event: EmotionEvent)
    func delete(event: EmotionEvent)
    func add(listener: @escaping EmotionEventsProviderListener)
}

fileprivate extension EmotionEvent {
    init(entity: StorageEntity) {
        date = entity.value(forKey: "date") as! Date
        name = entity.value(forKey: "name") as! String
        emotions = entity.value(forKey: "emotions") as! String
        color = entity.value(forKey: "color") as! String
    }
}

public final class EmotionEventsProviderImpl<EmotionEventEntity: StorageEntity> {
    
    // MARK: - Private
    
    private let storage: Storage
    
    // MARK: - Public
    
    public init(storage: Storage) {
        self.storage = storage
    }
}

extension EmotionEventsProviderImpl: EmotionEventsProvider {
    public var events: [EmotionEvent] {
        let entities: [EmotionEventEntity] = storage.get()
        return entities.map(EmotionEvent.init)
    }
    
    public func delete(event: EmotionEvent) {
        let entities: [EmotionEventEntity] = storage.get()
        let entity = entities.first { $0.value(forKey: "date") as! Date == event.date }!
        storage.delete(entity: entity)
    }
    
    public func add(listener: @escaping EmotionEventsProviderListener) {
        storage.add(listener: listener)
    }
    
    public func log(event: EmotionEvent) {
        let entity: EmotionEventEntity = storage.create()
        entity.setValue(event.date, forKey: "date")
        entity.setValue(event.name, forKey: "name")
        entity.setValue(event.emotions, forKey: "emotions")
        entity.setValue(event.color, forKey: "color")
        storage.add(entity: entity)
    }
}
