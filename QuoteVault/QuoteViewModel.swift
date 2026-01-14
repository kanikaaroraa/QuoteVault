//
//  QuoteViewModel.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class QuoteViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var favorites: Set<UUID> = [] // Stores IDs of liked quotes
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCategory: String? = nil
    
    // A simple logic: Pick a quote based on the day of the year
    var quoteOfTheDay: Quote? {
        guard !quotes.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % quotes.count
        return quotes[index]
    }
    
    // For Requirement 2: Filter by category/search
    var filteredQuotes: [Quote] {
        quotes.filter { quote in
            let matchesCategory = selectedCategory == nil || quote.category == selectedCategory
            let matchesSearch = searchText.isEmpty ||
                                quote.content.localizedCaseInsensitiveContains(searchText) ||
                                quote.author.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }
    
    init() {
        Task { await fetchData() }
    }
    
    func fetchData() async {
        isLoading = true
        do {
            // 1. Fetch Quotes
            let quotes: [Quote] = try await supabase.database
                .from("quotes")
                .select() // Select all columns
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.quotes = quotes
            
            // 2. Fetch User Favorites (for the heart icon)
            let userId = supabase.auth.currentUser?.id
            if let userId = userId {
                struct FavID: Decodable { let quote_id: UUID }
                let favs: [FavID] = try await supabase.database
                    .from("favorites")
                    .select("quote_id")
                    .eq("user_id", value: userId)
                    .execute()
                    .value
                
                self.favorites = Set(favs.map { $0.quote_id })
            }
        } catch {
            print("Error fetching data: \(error)")
        }
        isLoading = false
    }
    
    func toggleFavorite(quote: Quote) {
        Task {
            guard let userId = supabase.auth.currentUser?.id else { return }
            
            if favorites.contains(quote.id) {
                // Remove favorite
                favorites.remove(quote.id)
                try? await supabase.database.from("favorites")
                    .delete()
                    .eq("user_id", value: userId)
                    .eq("quote_id", value: quote.id)
                    .execute()
            } else {
                // Add favorite
                favorites.insert(quote.id)
                let newFav = ["user_id": userId.uuidString, "quote_id": quote.id.uuidString]
                try? await supabase.database.from("favorites").insert(newFav).execute()
            }
        }
    }
}
