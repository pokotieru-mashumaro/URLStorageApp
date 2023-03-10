//
//  Category.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI

enum Category: String, CaseIterable {
    case general = "一般"
    case wantItem = "欲しいもの"
    case idea = "アイデア"
    case goal = "目標"
    case failure = "失敗"
    case other = "その他"
    
    var color: Color {
        switch self {
        case .general:
            return .gray.opacity(0.8)
        case .wantItem:
            return .green
        case .idea:
            return .pink
        case .goal:
            return .blue
        case .failure:
            return .purple
        case .other:
            return .brown
        }
    }
}

 
