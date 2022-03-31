import Foundation

public protocol Settings: AnyObject {
    typealias Observer = (Settings) -> Void
    func add(observer: @escaping Observer) -> AnyObject

    var range: (min: Date?, max: Date?) { get set }
    var protectSensitiveData: Bool { get set }
    var useFaceId: Bool { get set }
    var useLegacyLayout: Bool { get set }
    var useExpandedDiary: Bool { get set }
    var reduceAnimation: Bool { get set }
    var useLegacyDiary: Bool { get set }
}
