public protocol EventNameUseCaseOutput: class {
    func present(selectedEmotions: [String])
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

public class EventNameUseCaseImpl {
    
    // MARK: - Private
    
    private let selectedEmotions: [String]
    private var description: String?
    
    // MARK: - Public
    
    public weak var output: EventNameUseCaseOutput!
    public init(selectedEmotions: [String]) {
        self.selectedEmotions = selectedEmotions
    }
}

extension EventNameUseCaseImpl: EventNameUseCase {
    public func eventOutputReady() {
        output.present(selectedEmotions: selectedEmotions)
    }
    
    public func eventBack() {
        output.presentBack()
    }
    
    public func event(descriptionChanged: String?) {
        description = descriptionChanged
        output.present(addAvailable: (description ?? "").count > 0)
    }
    
    public func eventAdd() {
        output.presentEmotions()
    }
}
