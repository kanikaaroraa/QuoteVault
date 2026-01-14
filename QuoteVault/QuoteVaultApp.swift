//
//  QuoteVaultApp.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//
import SwiftUI

@main
struct QuoteVaultApp: App {
    // 1. Create the single shared instance of AuthViewModel here
    @StateObject var authVM = AuthViewModel()
    
    // Your existing dark mode setting
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            Group {
                // 2. The "Switcher" Logic
                if authVM.isAuthenticated {
                    MainView()
                        .transition(.opacity) // Smooth fade
                } else {
                    LoginView()
                        .transition(.opacity)
                }
            }
            // 3. Inject the VM so all other views can use it
            .environmentObject(authVM)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
