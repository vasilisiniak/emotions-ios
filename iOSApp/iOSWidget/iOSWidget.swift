import WidgetKit
import SwiftUI

@main struct iOSWidget: Widget {
    let kind: String = "iOSWidget"

    var body: some WidgetConfiguration {
        let res = StaticConfiguration(kind: kind, provider: WidgetProvider()) { entry in
            EmotionsColorsView(entry: entry)
        }
        .configurationDisplayName("Карта эмоций")
        .description("Отображает цветовую карту эмоций, вызывнных событиями из дневника")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])

        if #available(iOSApplicationExtension 15.0, *) {
            return res.contentMarginsDisabled()
        }
        else {
            return res
        }
    }
}

struct iOSWidget_Previews: PreviewProvider {
    static var previews: some View {
        EmotionsColorsView(entry: WidgetProvider.snapshotEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
