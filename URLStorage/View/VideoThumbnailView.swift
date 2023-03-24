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
    var widget: (UIImage) -> ()
    @State var thumbnailUrl: String?
    
    var body: some View {
        VStack {
            if let thumbnailUrl = thumbnailUrl {
                KFImage.url(URL(string: thumbnailUrl))
                    .onSuccess { result in
                        widget(result.image)
                    }
                    .placeholder {
                        ZStack {
                            Color.gray
                            
                            Text("画像の生成に\n失敗しました")
                                .font(.caption2)
                        }
                    }
                    .resizable()
                    .frame(width: 100, height: 80)
                    .scaledToFill()
                    .clipped()
                    .cornerRadius(10)
            } else {
                EmptyView()
            }
        }
        .task {
            thumbnailUrl = await getThumbnailUrl(url: url)
        }
    }
}

struct AddOrEditVideoThumbnailView: View {
    @Binding var url: String
    @State var thumbnailUrl: String?
    
    var body: some View {
        VStack {
            if let thumbnailUrl = thumbnailUrl {
                KFImage.url(URL(string: thumbnailUrl))
                    .placeholder {
                        ZStack {
                            Color.gray
                            
                            Text("画像の生成に\n失敗しました")
                                .font(.caption2)
                        }                    }
                    .resizable()
                    .placeholder {
                        loadImage()
                    }
                    .frame(width: 100, height: 80)
                    .scaledToFill()
                    .clipped()
                    .cornerRadius(10)
            } else {
                loadImage()
            }
        }
        .task {
            thumbnailUrl = await getThumbnailUrl(url: url)
        }
        .onChange(of: url) { newValue in
            thumbnailUrl = nil
            Task {
                thumbnailUrl = await getThumbnailUrl(url: url)
            }
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

struct FullScreenVideoThumbnailView: View {
    let url: String
    @State var thumbnailUrl: String?
    
    var body: some View {
        VStack {
            if let thumbnailUrl = thumbnailUrl {
                KFImage.url(URL(string: thumbnailUrl))
                    .resizable()
            } else {
                EmptyView()
            }
        }
        .task {
            thumbnailUrl = await getThumbnailUrl(url: url)
        }
    }
}

func getThumbnailUrl(url: String) async -> String? {
    guard let url = URL(string: url) else {
        return nil
    }
    
    do {
        let html = try String(contentsOf: url, encoding: .utf8)
        let doc = try SwiftSoup.parse(html)
        var thumbnail: Element? = try doc.select("meta[property=og:image]").first()
        if thumbnail == nil {
            thumbnail = try doc.select("link[rel=image_src]").first()
        }
        return try thumbnail?.attr("content")
    } catch {
        print("Error getting thumbnail URL: \(error.localizedDescription)")
        return nil
    }
}
