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
    @State var thumbnailUrl: String?
    
    var body: some View {
        VStack {
            if let thumbnailUrl = thumbnailUrl {
                KFImage.url(URL(string: thumbnailUrl))
                    .placeholder {
                        Color.gray
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
            thumbnailUrl = await getThumbnailUrl()
        }
    }
    
    //非同期にすれば完璧
    private func getThumbnailUrl() async -> String? {
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
}

struct AddOrEditVideoThumbnailView: View {
    @Binding var url: String
    @State var thumbnailUrl: String?
    
    var body: some View {
        VStack {
            if let thumbnailUrl = thumbnailUrl {
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
                loadImage()
            }
        }
        .task {
            thumbnailUrl = await getThumbnailUrl()
        }
        .onChange(of: url) { newValue in
            thumbnailUrl = nil
            Task {
                thumbnailUrl = await getThumbnailUrl()
            }
        }
    }
    
    private func getThumbnailUrl() async -> String? {
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

