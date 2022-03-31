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
