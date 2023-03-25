//
//  MediumSizeView.swift
//  URLVaultWidgetExtension
//
//  Created by iniad on 2023/03/24.
//

import SwiftUI
import WidgetKit

struct MediumSizeView: View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            Image(uiImage: entry.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            VStack {
                HStack(spacing: 16) {
                    square(icon: "link.circle")
                }
                .offset(x: -10, y: 40)
                .hAlign(.trailing)
            }
        }
    }
}
