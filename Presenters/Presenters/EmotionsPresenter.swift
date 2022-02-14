import UseCases

public protocol EmotionsPresenterOutput: AnyObject {
    func showEmotions()
    func show(message: String, title: String, button: String)
}

private extension EmotionsUseCaseObjects.News {
    var info: String {
        switch self {
        case .v_1_7_addedLove: return "Вы могли заметить, что из приложения пропала секция Стыд — это потому что в ней было мало эмоций и по некоторым классификациям они относятся к Страху — туда они и перемещены. Зато вместо них новая секция — Любовь!"
        case .v_1_8_addedFaceId: return "Дневник теперь можно защитить паролем, который можно включить на вкладке настроек"
        case .v_1_9_emotionsRedesign: return "Список эмоций теперь выглядит по-новому, надеюсь, вам нравится! (Но к старой версии можно вернуться на вкладке настроек.)"
        case .v_1_10_eventDetails: return "Теперь к записи события в дневнике можно добавлять комментарий. А скоро и сам дневник станет более компактным!"
        case .v_1_11_compactDiary: return "Теперь дневник по умолчанию показывается в однострочном режиме — полная запись отображается при тапе на неё. Вернуть прежний вид можно на вкладке настроек"
        }
    }
}

public protocol EmotionsPresenter {
    func eventViewReady()
    func eventViewIsShown()
}

public final class EmotionsPresenterImpl {

    // MARK: - Public

    public weak var output: EmotionsPresenterOutput!
    public var useCase: EmotionsUseCase!

    public init() {}
}

extension EmotionsPresenterImpl: EmotionsPresenter {
    public func eventViewReady() {
        useCase.eventOutputReady()
    }

    public func eventViewIsShown() {
        useCase.eventViewIsShown()
    }
}

extension EmotionsPresenterImpl: EmotionsUseCaseOutput {
    public func present(news: [EmotionsUseCaseObjects.News]) {
        let info = news
            .map { "▷ \($0.info)" }
            .joined(separator: "\n\n")
        output.show(message: info, title: "Что нового", button: "OK")
    }

    public func presentEmotions() {
        output.showEmotions()
    }
}
