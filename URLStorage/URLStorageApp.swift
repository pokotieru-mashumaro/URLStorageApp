//
//  URLStorageApp.swift
//  URLStorage
//
//  Created by iniad on 2023/03/10.
//

import SwiftUI

@main
struct URLStorageApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
