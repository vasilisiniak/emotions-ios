import Foundation

extension NSObject {
    public static func create<T>(block: (T) -> ()) -> T where T: NSObject {
        let object = T()
        block(object)
        return object
    }
}
