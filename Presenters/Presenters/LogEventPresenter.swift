import UIKit
import UseCases

public protocol LogEventPresenterOutput: AnyObject {
    func showEmotions()
    func show(message: String, button: String)
    func showWidgetAlert(message: String, okButton: String, infoButton: String)
}

public protocol LogEventPresenter {
    func eventViewReady()
    func eventEventCreated()
    func eventWidgetInfo()
}

public final class LogEventPresenterImpl {
    
    // MARK: - Public
    
    public weak var output: LogEventPresenterOutput!
    public var useCase: LogEventUseCase!
    
    public init() {}
}

extension LogEventPresenterImpl: LogEventPresenter {
    public func eventEventCreated() {
        useCase.eventEventCreated()
    }
    
    public func eventViewReady() {
        useCase.eventOutputReady()
    }
    
    public func eventWidgetInfo() {
        useCase.eventWidgetInfo()
    }
}

extension LogEventPresenterImpl: LogEventUseCaseOutput {
    public func presentDairyInfo() {
        output.show(message: "Запись сделана. Её можно увидеть на вкладке дневника", button: "OK")
    }
    
    public func presentColorMapInfo() {
        output.show(message: "Теперь доступна цветовая карта эмоций. Её можно увидеть на соответствующей вкладке", button: "OK")
    }
    
    public func presentWidgetInfo() {
        output.showWidgetAlert(message: "Можно добавить виджет с цветовой картой эмоций на экран «Домой»", okButton: "OK", infoButton: "Как это сделать")
    }
    
    public func presentWidgetHelp() {
        UIApplication.shared.open(URL(string: "https://support.apple.com/ru-ru/HT207122")!)
    }

    public func presentEmotions() {
        output.showEmotions()
    }
}
