import UIKit

public struct EmotionsGroup {
    
    // MARK: - Public
    
    public let name: String
    public let color: String
    public let emotions: [String]
}

extension EmotionsGroup: Decodable {}
