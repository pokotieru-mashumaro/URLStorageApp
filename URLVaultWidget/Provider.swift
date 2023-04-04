//
//  URLVaultWidget.swift
//  URLVaultWidget
//
//  Created by iniad on 2023/03/23.
//

import WidgetKit
import SwiftUI
import SwiftSoup
import Kingfisher

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "", group: "", url: "", image: UIImage())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "", group: "", url: "", image: UIImage())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        var title = ""
        var group = ""
        var url = ""
        var image = UIImage()
        let userDefaults = UserDefaults(suiteName: "group.com.kotaro.URLVaultApp")
        if let userDefaults = userDefaults {
            title = userDefaults.string(forKey: "title") ?? ""
            group = userDefaults.string(forKey: "group") ?? ""
            url = userDefaults.string(forKey: "url") ?? ""
            image = userDefaults.image(forKey: "image")
        }

        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            // UserDefaultsから取得した文字列をセット
            let entry = SimpleEntry(date: entryDate, title: title, group: group, url: url, image: image)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let group: String
    let url: String
    let image: UIImage
}

struct URLVaultWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    @State private var thumbnailImage: UIImage? = nil
    let userDefaults = UserDefaults(suiteName: "group.com.kotaro.URLVaultApp")
    let url = "https://www.youporn.com/watch/16996960/watch-this-hot-real-life-couple-enjoy-intense-orgasms-together/"
    var body: some View {
        VStack {
            switch widgetFamily {
            case .systemSmall:
                SmallSizeView(entry: entry)
            case .systemMedium:
                MediumSizeView(entry: entry)
            case .systemLarge:
                LargeSizeView(entry: entry)
            default:
                Text("生成失敗")
            }
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
        URLVaultWidgetEntryView(entry: SimpleEntry(date: Date(), title: "可愛い女の子", group: "", url: "https://qiita.com/ken_sasaki2/items/698b28968b4fd72bbcf2", image: UIImage()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

struct square: View {
    @Environment(\.colorScheme) private var colorScheme
    var icon: String
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 110, height: 55)
                .foregroundColor(colorScheme == .dark ? Color.black.opacity(0.6): Color.white.opacity(0.6))
                .cornerRadius(15)
                .shadow(color: Color.white, radius: 10)
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.primary)
        }
    }
}

extension View {
    func hAlign(_ alignment: Alignment) -> some View {
          self.frame(maxWidth: .infinity, alignment: alignment)
      }
      
      func vAlign(_ alignment: Alignment) -> some View {
          self.frame(maxHeight: .infinity, alignment: alignment)
      }
}
