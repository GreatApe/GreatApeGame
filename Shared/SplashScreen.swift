//
//  SplashScreen.swift
//  GreatApeGame (iOS)
//
//  Created by Gustaf Kugelberg on 06/07/2022.
//

import SwiftUI

//struct UnfairLogo: Shape {
//    func path(in rect: CGRect) -> Path {
//        <#code#>
//    }
//}

struct SplashScreen: View {
    let vm: ViewModel

    var body: some View {
        Text("")
    }

    struct ViewModel {
        let tapBackground: () -> Void
        let finished: () -> Void
        let delay: Double = 0.5
    }
}
