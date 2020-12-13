import Foundation

public protocol EmotionsGroupsProvider {
    var emotionsGroups: [EmotionsGroup] { get }
}

public class EmotionsGroupsProviderImpl: EmotionsGroupsProvider {
    
    // MARK: - Public
    
    public let emotionsGroups: [EmotionsGroup]
    
    public init(url: URL) {
        let data = try! Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        emotionsGroups = try! decoder.decode(Array<EmotionsGroup>.self, from: data)
    }
}
