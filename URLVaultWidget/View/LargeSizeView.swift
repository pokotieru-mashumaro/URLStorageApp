//
//  LargeSizeView.swift
//  URLVaultWidgetExtension
//
//  Created by iniad on 2023/03/24.
//

import SwiftUI
import WidgetKit

struct LargeSizeView: View {
    @Environment(\.colorScheme) private var colorScheme
    var entry: SimpleEntry
    
    var body: some View {
        ZStack {
            Image(uiImage: entry.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            VStack {
                HStack(spacing: 20) {
                    largeSquare(icon: "house")
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
                .frame(width: 240, height: 55)
                .foregroundColor(colorScheme == .dark ? Color.black.opacity(0.6): Color.white.opacity(0.6))
                .cornerRadius(15)
                .shadow(color: Color.white, radius: 10)
            
            Image(systemName: icon)
                .resizable()
                .foregroundColor(.primary)
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }
}

