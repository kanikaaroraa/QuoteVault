//
//  FavoritesView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var vm: QuoteViewModel // Pass the existing ViewModel
    
    var body: some View {
        NavigationView {
            Group {
                if vm.favorites.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No favorites yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Go explore and heart some quotes!")
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        // Filter quotes to show only those whose IDs are in the favorites Set
                        ForEach(vm.quotes.filter { vm.favorites.contains($0.id) }) { quote in
                            QuoteCard(quote: quote, isFavorite: true) {
                                vm.toggleFavorite(quote: quote)
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView(vm: QuoteViewModel())
}
