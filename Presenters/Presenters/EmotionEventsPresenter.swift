import Foundation
import UIKit
import UseCases

public enum EmotionEventsPresenterObjects {

    public struct EventsGroup {

        public struct Event {

            // MARK: - Private

            private static let timeFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ru_RU")
                formatter.dateStyle = .none
                formatter.timeStyle = .short
                return formatter
            }()

            private static let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ru_RU")
                formatter.dateFormat = "d MMMM, EEEE"
                return formatter
            }()

            private static let dateYearFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ru_RU")
                formatter.dateFormat = "d MMMM, EEEE, y"
                return formatter
            }()

            private static func formatter(for date: Date) -> DateFormatter {
                (date.year == Date().year) ? dateFormatter : dateYearFormatter
            }

            // MARK: - Fileprivate

            let date: Date
            let dateString: String

            init(event: EmotionEventsUseCaseObjects.Event) {
                date = event.date
                timeString = Event.timeFormatter.string(from: event.date)
                dateString = Event.formatter(for: event.date).string(from: event.date)
                name = event.name
                details = event.details
                emotions = event.emotions
                color = UIColor(hex: event.color)
            }

            // MARK: - Public

            public let timeString: String
            public let name: String
            public let details: String?
            public let emotions: String
            public let color: UIColor
        }

        // MARK: - Fileprivate

        let date: Date

        // MARK: - Public

        public let dateString: String
        public let events: [Event]
    }
}

public protocol EmotionEventsPresenterOutput: AnyObject {
    func show(noDataText: String, button: String)
    func show(noDataHidden: Bool)
    func show(blur: Bool)
    func show(eventsGroups: [EmotionEventsPresenterObjects.EventsGroup])
    func show(message: String, button: String)
    func showFaceIdAlert(message: String, okButton: String, infoButton: String)
    func show(indexPath: IndexPath)
}

public protocol EmotionEventsRouter: AnyObject {
    func routeEmotions()
    func route(shareText: String)
    func route(editEvent: EmotionEventsPresenterObjects.EventsGroup.Event, date: Date)
    func route(url: String)
}

public protocol EmotionEventsPresenter {
    var deleteTitle: String { get }
    var editTitle: String { get }
    var title: String { get }

    func expanded(_ indexPath: IndexPath) -> Bool

    func eventViewReady()
    func eventViewWillAppear()
    func eventViewDidAppear()
    func event(shareIndexPath: IndexPath)
    func event(deleteIndexPath: IndexPath)
    func event(editIndexPath: IndexPath)
    func event(tap: IndexPath)
    func eventAddTap()
    func eventInfoTap()
    func eventStartUnsafe()
    func eventEndUnsafe()
    func eventFaceIdInfo()
}

public final class EmotionEventsPresenterImpl {

    // MARK: - Private

    private var events: [EmotionEventsUseCaseObjects.Event] = []
    private var groups: [EmotionEventsPresenterObjects.EventsGroup] = []

    private var expandAll = false
    private var expandedEvents: Set<IndexPath> = []

    // MARK: - Public

    public weak var output: EmotionEventsPresenterOutput!
    public weak var router: EmotionEventsRouter!
    public var useCase: EmotionEventsUseCase!

    public init() {}
}

extension EmotionEventsPresenterImpl: EmotionEventsPresenter {
    public func eventViewWillAppear() {
        useCase.eventOutputToBeShown()
    }

    public func eventViewDidAppear() {
        useCase.eventOutputIsShown(info: "Получить доступ к дневнику")
    }

    public func eventStartUnsafe() {
        useCase.eventStartUnsafe()
    }

    public func eventEndUnsafe() {
        useCase.eventEndUnsafe(info: "Получить доступ к дневнику")
    }

    public var title: String {
        "Дневник"
    }

    public var deleteTitle: String {
        "Удалить"
    }

    public var editTitle: String {
        "Изменить"
    }

    public func eventAddTap() {
        useCase.eventAdd()
    }

    public func eventViewReady() {
        output.show(noDataText: "Здесь отображаются события и эмоции, которые они вызвали. Но пока записей нет", button: "Добавить запись")
        useCase.eventOutputReady()
    }

    public func event(shareIndexPath: IndexPath) {
        let event = groups[shareIndexPath.section].events[shareIndexPath.row]
        useCase.event(shareEvent: events.first { $0.date == event.date }!)
    }

    public func event(deleteIndexPath: IndexPath) {
        let event = groups[deleteIndexPath.section].events[deleteIndexPath.row]
        useCase.event(deleteEvent: events.first { $0.date == event.date }!)
    }

    public func event(editIndexPath: IndexPath) {
        let event = groups[editIndexPath.section].events[editIndexPath.row]
        useCase.event(editEvent: events.first { $0.date == event.date }!)
    }

    public func event(tap indexPath: IndexPath) {
        guard !expandAll else { return }

        if expandedEvents.contains(indexPath) {
            expandedEvents.remove(indexPath)
        }
        else {
            expandedEvents.insert(indexPath)
        }

        output.show(indexPath: indexPath)
    }

    public func eventFaceIdInfo() {
        useCase.eventFaceIdInfo()
    }

    public func present(url: String) {
        router.route(url: url)
    }

    public func eventInfoTap() {
        useCase.eventInfoTap()
    }

    public func expanded(_ indexPath: IndexPath) -> Bool {
        useCase.eventToggleExpand()
        return expandAll || expandedEvents.contains(indexPath)
    }
}

extension EmotionEventsPresenterImpl: EmotionEventsUseCaseOutput {
    public func presentEmotions() {
        router.routeEmotions()
    }

    public func presentSwipeInfo() {
        output.show(message: "Свайпните запись влево чтобы редактировать или удалить", button: "ОК")
    }

    public func present(noData: Bool) {
        output.show(noDataHidden: !noData)
    }

    public func present(blur: Bool) {
        output.show(blur: blur)
    }

    public func present(shareEvent: EmotionEventsUseCaseObjects.Event) {
        var text = "Что произошло: \(shareEvent.name)"
        text += "\nМои эмоции: \(shareEvent.emotions)"
        if let details = shareEvent.details {
            text += "\nКомментарии: \(details.replacingOccurrences(of: "\n", with: "\n\t"))"
        }
        router.route(shareText: text)
    }

    public func present(events: [EmotionEventsUseCaseObjects.Event], expanded: Bool) {
        self.events = events
        self.expandAll = expanded
        expandedEvents.removeAll()

        let events = events.map(EmotionEventsPresenterObjects.EventsGroup.Event.init(event:))
        let groupedEvents = Dictionary(grouping: events) { $0.dateString }

        groups = groupedEvents
            .map { EmotionEventsPresenterObjects.EventsGroup(date: $0.value.first!.date, dateString: $0.key, events: $0.value) }
            .sorted { $0.date > $1.date }
        output.show(eventsGroups: groups)
    }

    public func present(editEvent: EmotionEventsUseCaseObjects.Event) {
        router.route(editEvent: EmotionEventsPresenterObjects.EventsGroup.Event(event: editEvent), date: editEvent.date)
    }

    public func presentFaceIdError() {
        output.showFaceIdAlert(
            message: "Для функции защиты паролем нужно включить код-пароль в настройках устройства",
            okButton: "OK",
            infoButton: "Как это сделать"
        )
    }
}
