//
//  URLVaultWidget.swift
//  URLVaultWidget
//
//  Created by iniad on 2023/03/23.
//

import WidgetKit
import SwiftUI
import SwiftSoup

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "", url: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "", url: "")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        var title = ""
        var url = ""
        let userDefaults = UserDefaults(suiteName: "group.com.kotaro.URLVaultApp")
        if let userDefaults = userDefaults {
            title = userDefaults.string(forKey: "title") ?? ""
            url = userDefaults.string(forKey: "url") ?? ""
        }

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            // UserDefaultsから取得した文字列をセット
            let entry = SimpleEntry(date: entryDate, title: title, url: url)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let url: String
}

struct URLVaultWidgetEntryView : View {
    var entry: Provider.Entry
    @State private var thumbnailImage: UIImage? = nil
    let userDefaults = UserDefaults(suiteName: "group.com.kotaro.URLVaultApp")
    let url = "https://www.youporn.com/watch/16996960/watch-this-hot-real-life-couple-enjoy-intense-orgasms-together/"
    var body: some View {
        VStack {
            Text("gg")
        }
    }
}

struct URLVaultWidget: Widget {
    let kind: String = "URLVaultWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            URLVaultWidgetEntryView(entry: entry)

        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies(supportedFamilies)
    }
    
    private var supportedFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [
                .systemSmall,
                .systemMedium,
                .systemLarge,
                .systemExtraLarge,
                .accessoryInline,
                .accessoryCircular,
                .accessoryRectangular
            ]
        } else {
            return [
                .systemSmall,
                .systemMedium,
                .systemLarge
            ]
        }
    }
}

struct URLVaultWidget_Previews: PreviewProvider {
    static var previews: some View {
        URLVaultWidgetEntryView(entry: SimpleEntry(date: Date(), title: "可愛い女の子", url: "https://www.youporn.com/watch/16996960/watch-this-hot-real-life-couple-enjoy-intense-orgasms-together/"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
