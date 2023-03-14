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

func getGroupColor(color: String) -> GroupColor {
    switch color {
    case "gray":
        return GroupColor.gray
    case "green":
        return GroupColor.green
    case "pink":
        return GroupColor.pink
    case "blue":
        return GroupColor.blue
    case "purple":
        return GroupColor.purple
    case "brown":
        return GroupColor.brown
    default:
        return GroupColor.gray
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
    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    let select_date: String = "\(dateComponents.year!)/\(String(format: "%02d", dateComponents.month!))/\(String(format: "%02d", dateComponents.day!))/\(String(format: "%02d", dateComponents.hour!)):\(String(format: "%02d", dateComponents.minute!))"
    return select_date
}
