//
//  GreatApeGameApp.swift

import SwiftUI

@main
struct GreatApeGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Store())
        }
    }
}
