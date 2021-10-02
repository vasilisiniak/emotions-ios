import Model

public protocol EmotionNotFoundUseCaseOutput: AnyObject {
    func present(url: String)
    func present(emailTheme: String, email: String)
}

public protocol EmotionNotFoundUseCase {
    func eventSuggest()
    func eventEmailInfo()
}

public final class EmotionNotFoundUseCaseImpl {

    // MARK: - Private

    private let analytics: AnalyticsManager
    private let email: String
    private let emailInfo: String
    private let emailTheme: String

    // MARK: - Public

    public weak var output: EmotionNotFoundUseCaseOutput!
    public init(analytics: AnalyticsManager, email: String, emailInfo: String, emailTheme: String) {
        self.analytics = analytics
        self.email = email
        self.emailInfo = emailInfo
        self.emailTheme = emailTheme
    }
}

extension EmotionNotFoundUseCaseImpl: EmotionNotFoundUseCase {
    public func eventEmailInfo() {
        output.present(url: emailInfo)
    }

    public func eventSuggest() {
        analytics.track(.suggestEmotion)
        output.present(emailTheme: "\(emailTheme)[Emotion]", email: email)
    }
}
