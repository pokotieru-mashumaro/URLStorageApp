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
                    Button {
                        print("🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫🇨🇫")
                        openURL(URL(string: entry.url)!)
                    } label: {
                        largeSquare(icon: "link.circle")
                            .contentShape(Rectangle())
                    }
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
    private func openURL(_ url: URL) {
          let context = ExtensionContext()
          context.open(url)
      }
}

struct ExtensionContext {
    func open(_ url: URL) {
        let selector = sel_registerName("openURL:")
        var responder = self as! UIResponder?
        while responder != nil {
            if responder!.responds(to: selector) {
                responder!.perform(selector, with: url)
                return
            }
            responder = responder?.next
        }
    }
}

