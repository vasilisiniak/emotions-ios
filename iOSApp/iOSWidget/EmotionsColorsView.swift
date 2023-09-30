import SwiftUI

struct EmotionsColorsView : View {
    var entry: WidgetProvider.Entry

    var body: some View {
        if entry.colors.count > 1 {
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: entry.colors.map(Color.init)),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .widgetBackground(Color.clear)
        }
        else {
            ZStack {
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: WidgetProvider.snapshotEntry.colors.map(Color.init)),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                Text("Недостаточно записей событий").multilineTextAlignment(.center)
            }
            .widgetBackground(Color.clear)
        }
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        }
        else {
            return background(backgroundView)
        }
    }
}
