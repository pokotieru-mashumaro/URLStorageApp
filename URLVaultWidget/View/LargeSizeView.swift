//
//  LargeSizeView.swift
//  URLVaultWidgetExtension
//
//  Created by iniad on 2023/03/24.
//

import SwiftUI
import WidgetKit

struct LargeSizeView: View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            Image(uiImage: entry.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            VStack {
                HStack(spacing: 20) {
                    largeSquare(icon: "house")
                                            
                    largeSquare(icon: "link.circle")
                }
            }
            .offset(y: -10)
            .hAlign(.center)
            .vAlign(.bottom)
        }
    }
    
    @ViewBuilder
    func largeSquare(icon: String) -> some View {
        ZStack {
            Rectangle()
                .frame(width: 100, height: 55)
                .foregroundColor(.primary.opacity(0.6))
                .cornerRadius(15)
                .shadow(color: Color.white, radius: 10)
            
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }
}
