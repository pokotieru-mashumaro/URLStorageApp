//
//  URLVaultWidgetBundle.swift
//  URLVaultWidget
//
//  Created by iniad on 2023/03/23.
//

import WidgetKit
import SwiftUI

import WidgetKit
import SwiftUI

@main
struct URLVaultWidgetBundle: WidgetBundle {
    var body: some Widget {
        URLVaultWidget()
    }
}

//
//@main
//struct URLVaultWidget: Widget {
//    let kind: String = "URLVaultWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            WidgetView(entry: entry)
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
//        .supportedFamilies(supportedFamilies)
//    }
//    private var supportedFamilies: [WidgetFamily] {
//        if #available(iOSApplicationExtension 16.0, *) {
//            return [
//                .systemSmall,
//                .systemMedium,
//                .systemLarge,
//                .systemExtraLarge,
//            ]
//        } else {
//            return [
//                .systemSmall,
//                .systemMedium,
//                .systemLarge
//            ]
//        }
//    }
//}
//
//struct WidgetView: View {
//    @Environment(\.widgetFamily) var widgetFamily
//    var entry: Provider.Entry
//
//    var body: some View {
//        switch widgetFamily {
//        case .systemSmall:
//            SmallSizeView(entry: entry)
//        case .systemMedium:
//            MediumSizeView(entry: entry)
//        case .systemLarge:
//            LargeSizeView(entry: entry)
//        case .systemExtraLarge:
//            ExtraLargeSizeView(entry: entry)
//        default:
//            Text("v")
//        }
//    }
//}
