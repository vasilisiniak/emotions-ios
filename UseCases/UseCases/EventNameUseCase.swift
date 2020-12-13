public protocol EventNameUseCaseOutput: class {
    func present(title: String)
    func present(backButton: String)
    func present(addButton: String)
    func present(addButtonEnabled: Bool)
    func present(placeholder: String)
    func present(selectedEmotions: [String])
    func presentKeyboard()
    func presentBack()
    func presentEmotions()
}

public protocol EventNameEventsHandler {
    func eventViewReady()
    func eventViewDidAppear()
    func eventBackTap()
    func event(descriptionChanged: String?)
    func eventAddTap()
}

public protocol EventNameUseCase: EventNameEventsHandler {}

public class EventNameUseCaseImpl: EventNameUseCase {
    
    // MARK: - Private
    
    private let selectedEmotions: [String]
    private var description: String?
    
    // MARK: - Public
    
    public weak var output: EventNameUseCaseOutput!
    
    public init(selectedEmotions: [String]) {
        self.selectedEmotions = selectedEmotions
    }
}

extension EventNameUseCaseImpl: EventNameEventsHandler {
    public func eventViewDidAppear() {
        output.presentKeyboard()
    }
    
    public func eventViewReady() {
        output.present(title: "Введите событие")
        output.present(backButton: "❮Назад")
        output.present(addButton: "Добавить")
        output.present(addButtonEnabled: false)
        output.present(placeholder: "Описание события")
        output.present(selectedEmotions: selectedEmotions)
    }
    
    public func eventBackTap() {
        output.presentBack()
    }
    
    public func event(descriptionChanged: String?) {
        description = descriptionChanged
        output.present(addButtonEnabled: (description ?? "").count > 0)
    }
    
    public func eventAddTap() {
        output.presentEmotions()
    }
}
