import Utils
import WidgetKit
import SwiftUI

struct WidgetProvider: TimelineProvider {
    static let snapshotEntry = EmotionsColorsEntry(date: Date(), colors: [
        UIColor(hex: "ffec59"),
        UIColor(hex: "ffb997"),
        UIColor(hex: "b6cec7"),
        UIColor(hex: "6b3074"),
        UIColor(hex: "6bb6bc")
    ])

    func placeholder(in context: Context) -> EmotionsColorsEntry {
        WidgetProvider.snapshotEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (EmotionsColorsEntry) -> ()) {
        completion(WidgetProvider.snapshotEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EmotionsColorsEntry>) -> ()) {
        let colors = AppGroup.emotionEventsProvider.events.filtered(range: AppGroup.settings.range).map { UIColor(hex: $0.color) }
        let entry = EmotionsColorsEntry(date: Date(), colors: colors)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}
