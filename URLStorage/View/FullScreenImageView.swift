//
//  FullScreenImageView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/12.
//

import SwiftUI

struct FullScreenImageView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var item: GroupItem?
    
    @State private var scale = 1.0
    @State private var lastScale = 1.0

    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                // 前回の拡大率に対して今回の拡大率の割合を計算
                let delta = value / lastScale
                // 前回からの拡大率の変更割合分を乗算する
                scale *= delta
                // 前回の拡大率を今回の拡大率で更新
                lastScale = value
            }
            .onEnded { value in
                // 次回のジェスチャー時に1.0から始まる為、終了時に1.0に変更する
                lastScale = 1.0
            }
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if item!.itemimage == nil {
                FullScreenVideoThumbnailView(url: item!.url ?? "")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(magnification)
            } else {
                Image(uiImage: UIImage(data: item!.itemimage!)!)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .gesture(magnification)
            }
        }
        .overlay {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            .hAlign(.leading)
            .vAlign(.top)
        }
    }
}

struct FullScreenImageView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
