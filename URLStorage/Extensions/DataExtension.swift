//
//  DataExtension.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import Foundation

extension Date {
    func toString(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
