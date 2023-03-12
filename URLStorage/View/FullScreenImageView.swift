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
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if item!.itemimage == nil {
                FullScreenVideoThumbnailView(url: item!.url ?? "")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(contentMode: .fit)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Image(uiImage: UIImage(data: item!.itemimage!)!)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(contentMode: .fit)
                    .edgesIgnoringSafeArea(.all)            }
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
