import CoreData

public final class CoreDataStorage {

    deinit {
        tokens.forEach { NotificationCenter.default.removeObserver($0) }
    }

    // MARK: - Private

    private let container: NSPersistentCloudKitContainer
    private let backgroudContext: NSManagedObjectContext
    private var tokens: [AnyObject] = []

    // MARK: - Public

    public init(model: String, url: URL, cloudKitGroup: String) {
        container = NSPersistentCloudKitContainer(name: model)

        let description = NSPersistentStoreDescription(url: url)
        description.type = NSSQLiteStoreType
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true

        #if !targetEnvironment(simulator)
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitGroup)
        #endif

        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { [container] _, error in
            if error != nil {
                fatalError(error.debugDescription)
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
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
        let changeName = NSManagedObjectContext.didChangeObjectsNotification
        tokens.append(NotificationCenter.default.addObserver(forName: changeName, object: nil, queue: .main) { _ in listener() })

        let saveName = NSManagedObjectContext.didSaveObjectsNotification
        tokens.append(NotificationCenter.default.addObserver(forName: saveName, object: nil, queue: .main) { _ in listener() })
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


fileprivate extension NSManagedObject {
    class var entityName: String {
        let name = NSStringFromClass(self)
        return name.components(separatedBy: ".").last!
    }
}

extension NSManagedObject: StorageEntity {}
