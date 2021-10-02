import MessageUI
import UseCases

public protocol EmotionNotFoundPresenterOutput: AnyObject {
    func show(info: String)
    func show(button: String)
    func showEmailAlert(message: String, okButton: String, infoButton: String)
}

public protocol EmotionNotFoundRouter: AnyObject {
    func route(emailTheme: String, email: String)
    func route(url: String)
    func routeClose()
}

public protocol EmotionNotFoundPresenter {
    func eventViewReady()
    func eventSuggest()
    func eventClose()
    func eventEmailInfo()
}

public final class EmotionNotFoundPresenterImpl {

    // MARK: - Private

    private func route(emailTheme: String, email: String) {
        guard MFMailComposeViewController.canSendMail() else {
            output.showEmailAlert(
                message: "Для предложения эмоции нужно добавить почтовый аккаунт в приложение «Почта»",
                okButton: "OK",
                infoButton: "Как это сделать"
            )
            return
        }
        router.route(emailTheme: emailTheme, email: email)
    }

    // MARK: - Public

    public weak var output: EmotionNotFoundPresenterOutput!
    public weak var router: EmotionNotFoundRouter!
    public var useCase: EmotionNotFoundUseCase!

    public init() {}
}

extension EmotionNotFoundPresenterImpl: EmotionNotFoundPresenter {
    public func eventEmailInfo() {
        useCase.eventEmailInfo()
    }

    public func eventSuggest() {
        useCase.eventSuggest()
    }
    
    public func eventClose() {
        router.routeClose()
    }
    
    public func eventViewReady() {
        output.show(info:
            """
            Возможно, вы не нашли свою эмоцию, потому что путаете её с чувством или состоянием.

            Например, смесь таких эмоций как злость и отчаяние могут вызывать состояние пустоты, а в состоянии фрустрации можно ощущать разочарование, тревогу, раздражение и отчаяние.

            Если этот анализ не помог, предложите, как пополнить список эмоций:
            """
        )
        output.show(button: "Предложить эмоцию")
    }
}

extension EmotionNotFoundPresenterImpl: EmotionNotFoundUseCaseOutput {
    public func present(url: String) {
        router.route(url: url)
    }

    public func present(emailTheme: String, email: String) {
        route(emailTheme: emailTheme, email: email)
    }
}
