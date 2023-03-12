//
//  Category.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI

enum GroupColor: String, CaseIterable {
    case gray = "gray"
    case green = "green"
    case pink = "pink"
    case blue = "blue"
    case purple = "purple"
    case brown = "brown"
    
    var color: Color {
        switch self {
        case .gray:
            return .gray.opacity(0.8)
        case .green:
            return .green
        case .pink:
            return .pink
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .brown:
            return .brown
        }
    }
    
    var name: String {
        switch self {
        case .gray:
            return "gray"
        case .green:
            return "green"
        case .pink:
            return "pink"
        case .blue:
            return "blue"
        case .purple:
            return "purple"
        case .brown:
            return "brown"
        }
    }
}

func getColor(color: String) -> Color {
    switch color {
    case "gray":
        return .gray.opacity(0.8)
    case "green":
        return .green
    case "pink":
        return .pink
    case "blue":
        return .blue
    case "purple":
        return .purple
    case "brown":
        return .brown
    default:
        return .gray.opacity(0.8)
    }
}

func dateToString(date: Date?) -> String {
    guard let date = date else { return "" }
    let calendar = Calendar(identifier: .gregorian)
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    let select_date: String = "\(dateComponents.year!)/\(dateComponents.month!)/\(dateComponents.day!)"
    return select_date
}
