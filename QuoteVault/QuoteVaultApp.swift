//
//  QuoteVaultApp.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import SwiftUI

@main
struct QuoteVaultApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            // We wrap LoginView in a ZStack or just apply the modifier
            LoginView()
                .preferredColorScheme(isDarkMode ? .dark : .light) 
        }
    }
}
