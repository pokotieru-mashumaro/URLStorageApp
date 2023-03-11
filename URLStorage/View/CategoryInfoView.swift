//
//  CategoryInfoView.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI

struct CategoryInfoView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        List {
            ForEach(GroupColor.allCases, id: \.rawValue) { category in
                HStack {
                    Circle()
                        .frame(width: 10)
                        .foregroundColor(category.color)
                    
                    Text(category.rawValue.uppercased())
                        .font(.system(size: 12))
                        .padding(.vertical, 5)
                    
                        .foregroundColor(category.color)
                    
                    Spacer()
                }
            }
        }
    }
}

struct CategoryInfoView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryInfoView()
    }
}
