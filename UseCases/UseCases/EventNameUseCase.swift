import Foundation
import Model

public protocol EventNameUseCaseOutput: class {
    func present(selectedEmotions: [String], color: String)
    func present(addAvailable: Bool)
    func presentBack()
    func presentEmotions()
}

public protocol EventNameUseCase {
    func eventOutputReady()
    func eventBack()
    func event(descriptionChanged: String?)
    func eventAdd()
}

public final class EventNameUseCaseImpl {
    
    // MARK: - Private
    
    private let provider: EmotionEventsProvider
    private let selectedEmotions: [String]
    private let color: String
    private var description: String?
    
    // MARK: - Public
    
    public weak var output: EventNameUseCaseOutput!
    
    public init(provider: EmotionEventsProvider, selectedEmotions: [String], color: String) {
        self.provider = provider
        self.selectedEmotions = selectedEmotions
        self.color = color
    }
}

extension EventNameUseCaseImpl: EventNameUseCase {
    public func eventOutputReady() {
        output.present(selectedEmotions: selectedEmotions, color: color)
    }
    
    public func eventBack() {
        output.presentBack()
    }
    
    public func event(descriptionChanged: String?) {
        description = descriptionChanged
        output.present(addAvailable: (description ?? "").count > 0)
    }
    
    public func eventAdd() {
        let event = EmotionEvent(date: Date(), name: description!, emotions: selectedEmotions.joined(separator: ", "), color: color)
        provider.log(event: event)
        output.presentEmotions()
    }
}
