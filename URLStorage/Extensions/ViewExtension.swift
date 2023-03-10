//
//  ViewExtension.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI

extension View {
    func hAlign(_ alignment: Alignment) -> some View {
          self.frame(maxWidth: .infinity, alignment: alignment)
      }
      
      func vAlign(_ alignment: Alignment) -> some View {
          self.frame(maxHeight: .infinity, alignment: alignment)
      }
}
