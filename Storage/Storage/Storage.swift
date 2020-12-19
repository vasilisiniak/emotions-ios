import CoreData

public typealias StorageListener = () -> ()

public protocol Storage {
    func create<T>() -> T
    func add(object: Any)
    func get<T>() -> [T]
    func add(listener: @escaping StorageListener)
}

fileprivate extension NSManagedObject {
    class var entityName: String {
        let name = NSStringFromClass(self)
        return name.components(separatedBy: ".").last!
    }
    
    var entityName: String {
        return (type(of: self) as NSManagedObject.Type).entityName
    }
}

public final class CoreDataStorage {
    
    // MARK: - Private
    
    private let container: NSPersistentContainer
    private let backgroudContext: NSManagedObjectContext
    
    // MARK: - Public
    
    public init(model: String, type: String = NSSQLiteStoreType) {
        container = NSPersistentContainer(name: model)
        
        let description = NSPersistentStoreDescription(url: container.persistentStoreDescriptions.first!.url!)
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
    public func add(listener: @escaping StorageListener) {
        let name = NSManagedObjectContext.didSaveObjectsNotification
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { _ in
            listener()
        }
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
    
    public func add(object: Any) {
        try! backgroudContext.save()
    }
}
