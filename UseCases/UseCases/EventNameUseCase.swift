public protocol EventNameUseCaseOutput: class {
    func present(title: String)
    func present(backButton: String)
    func present(placeholder: String)
    func present(selectedEmotions: [String])
    func presentKeyboard()
    func presentBack()
}

public protocol EventNameEventsHandler {
    func eventViewReady()
    func eventBackTap()
}

public protocol EventNameUseCase: EventNameEventsHandler {}

public class EventNameUseCaseImpl: EventNameUseCase {
    
    // MARK: - Private
    
    private let selectedEmotions: [String]
    
    // MARK: - Public
    
    public weak var output: EventNameUseCaseOutput!
    
    public init(selectedEmotions: [String]) {
        self.selectedEmotions = selectedEmotions
    }
}

extension EventNameUseCaseImpl: EventNameEventsHandler {
    public func eventViewReady() {
        output.present(title: "Введите событие")
        output.present(backButton: "Назад")
        output.present(placeholder: "Описание события")
        output.present(selectedEmotions: selectedEmotions)
        output.presentKeyboard()
    }
    
    public func eventBackTap() {
        output.presentBack()
    }
}
