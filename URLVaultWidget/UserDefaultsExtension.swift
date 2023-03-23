//
//  ThumbnailWidgetView.swift
//  URLVaultWidgetExtension
//
//  Created by iniad on 2023/03/23.
//

import SwiftUI


extension UserDefaults {
    // 参照するUserDefaults, Keyを取得, UIImageを返す
    func image(forKey: String) -> UIImage {
        // UserDefaultsからKeyを基にData型を参照
        let data = self.data(forKey: forKey)
        // UIImage型へ変換
        let returnImage = UIImage(data: data!)
        // UIImageを返す
        return returnImage!
    }

}
