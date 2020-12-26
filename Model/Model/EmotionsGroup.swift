import UIKit

public struct EmotionsGroup {
    
    public struct Emotion: Decodable {
        
        // MARK: - Public
        
        public let name: String
        public let meaning: String
    }
    
    // MARK: - Public
    
    public let name: String
    public let color: String
    public let emotions: [Emotion]
}

extension EmotionsGroup: Decodable {}
