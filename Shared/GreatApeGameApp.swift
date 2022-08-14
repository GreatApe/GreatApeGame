//
//  GreatApeGameApp.swift
//  Shared
//
//  Created by Gustaf Kugelberg on 05/06/2022.
//

import SwiftUI

@main
struct GreatApeGameApp: App {
//    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Store())
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
