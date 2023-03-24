//
//  SmallSizeView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/24.
//

import SwiftUI
import WidgetKit

struct SmallSizeView: View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            Image(uiImage: entry.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
      
                VStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        square(icon: "house")
                                                
                        square(icon: "link.circle")
                    }
                }
                .padding(.bottom, 6)
        }
    }
}
