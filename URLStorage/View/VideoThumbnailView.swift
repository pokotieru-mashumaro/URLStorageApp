//
//  VideoThumbnailView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI
import SwiftSoup
import Kingfisher

struct VideoThumbnailView: View {
    let url: String

    var body: some View {
        if let thumbnailUrl = getThumbnailUrl() {
            KFImage.url(URL(string: thumbnailUrl))
                .placeholder {
                    Color.gray
                }
                .resizable()
                .placeholder {
                    loadImage()
                }
                .frame(width: 100, height: 80)
                .scaledToFill()
                .clipped()
                .cornerRadius(10)
        } else {
            EmptyView()
        }
    }

    //非同期にすれば完璧
    private func getThumbnailUrl() -> String? {
        guard let url = URL(string: url) else {
            return nil
        }

        do {
            let html = try String(contentsOf: url, encoding: .utf8)
            let doc = try SwiftSoup.parse(html)
            let thumbnail = try doc.select("meta[property=og:image]").first()
            return try thumbnail?.attr("content")
        } catch {
            print("Error getting thumbnail URL: \(error.localizedDescription)")
            return nil
        }
    }
    
    @ViewBuilder
    func loadImage() -> some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 85, height: 85)
    }
}

struct VideoThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

