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
        case .v_1_12_editDate: return "У записей дневника теперь можно редактировать дату"
        case .v_1_13_icloud: return "Записи в дневнике теперь синхронизируются между всеми вашими устройствами через iCloud"
        case .v_1_15_search: return "Наконец-то добавлен поиск эмоций!"
        case .v_1_16_animation: return "Если вам не очень комфортно с перемещением ячеек при выборе эмоций, то это поведение теперь можно откатить к тому, как было раньше. Соответствующая опция добавлена в раздел настроек"
        case .v_1_17_diary: return "Я попробовал немного освежить страницу дневника, надеюсь, вам понравится! Старый вариант по-прежнему можно вернуть в настройках :)"
        case .v_1_19_appearance: return "Теперь в приложении можно выбрать светлую или тёмную тему. Опция доступна на вкладке настроек"
        case .v_1_21_trash: return "Теперь записи дневника при удалении помещаются в корзину"
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
