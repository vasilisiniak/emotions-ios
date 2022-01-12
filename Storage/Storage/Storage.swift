import CoreData

public typealias StorageListener = () -> ()

public protocol Storage {
    func create<T>() -> T
    func add<T>(entity: T)
    func delete<T>(entity: T)
    func save<T>(entity: T)
    func get<T>() -> [T]
    func add(listener: @escaping StorageListener)
}

public protocol StorageEntity {
    func setValue(_ value: Any?, forKey key: String)
    func value(forKey key: String) -> Any?
}

fileprivate extension NSManagedObject {
    class var entityName: String {
        let name = NSStringFromClass(self)
        return name.components(separatedBy: ".").last!
    }
}

public final class CoreDataStorage {

    deinit {
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Private

    private let container: NSPersistentContainer
    private let backgroudContext: NSManagedObjectContext
    private var tokens: [AnyObject] = []

    // MARK: - Public

    public init(model: String, type: String = NSSQLiteStoreType, url: URL? = nil) {
        container = NSPersistentContainer(name: model)

        let storeURL = container.persistentStoreDescriptions.first!.url!
        let description = NSPersistentStoreDescription(url: url ?? storeURL)
        description.type = type
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if error != nil {
                fatalError(error.debugDescription)
            }
        }
        backgroudContext = container.newBackgroundContext()
    }
}

extension CoreDataStorage: Storage {
    public func delete<T>(entity: T) {
        let entity = entity as! NSManagedObject
        backgroudContext.delete(backgroudContext.object(with: entity.objectID))
        try! backgroudContext.save()
    }

    public func add(listener: @escaping StorageListener) {
        let name = NSManagedObjectContext.didSaveObjectsNotification
        tokens.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { _ in
            listener()
        })
    }

    public func create<T>() -> T {
        let type = T.self as! NSManagedObject.Type
        return NSEntityDescription.insertNewObject(forEntityName: type.entityName, into: backgroudContext) as! T
    }

    public func get<T>() -> [T] {
        let type = T.self as! NSManagedObject.Type
        let request = NSFetchRequest<NSManagedObject>(entityName: type.entityName)
        return try! container.viewContext.fetch(request) as! [T]
    }

    public func add<T>(entity: T) {
        try! backgroudContext.save()
    }

    public func save<T>(entity: T) {
        let entity = entity as! NSManagedObject
        var context = entity.managedObjectContext
        repeat {
            try? context?.save()
            context = context?.parent
        } while context != nil
    }
}

extension NSManagedObject: StorageEntity {}
