//
//  MainView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import SwiftUI

struct MainView: View {
    @StateObject var quoteVM = QuoteViewModel() // Shared ViewModel
    
    var body: some View {
        TabView {
            HomeView(vm: quoteVM)
                .tabItem {
                    Label("Daily Wisdom", systemImage: "quote.bubble")
                }
            
            FavoritesView(vm: quoteVM)
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
            
            // We will build Settings later, but here is a placeholder
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainView()
}
