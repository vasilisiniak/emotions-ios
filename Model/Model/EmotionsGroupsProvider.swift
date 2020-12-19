import Foundation

public protocol EmotionsGroupsProvider {
    var emotionsGroups: [EmotionsGroup] { get }
}

public final class EmotionsGroupsProviderImpl {
    
    // MARK: - Public
    
    public let emotionsGroups: [EmotionsGroup]
    
    public init(url: URL) {
        let data = try! Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        emotionsGroups = try! decoder.decode(Array<EmotionsGroup>.self, from: data)
    }
}

extension EmotionsGroupsProviderImpl: EmotionsGroupsProvider {}
