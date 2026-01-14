//
//  HomeView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import SwiftUI

struct HomeView: View {
    
    // Controls the Share Sheet
    @State private var quoteToShare: Quote?
    
    // 👇 THIS controls the "Add to Collection" Sheet
    @State private var quoteForCollection: Quote?
    
    @StateObject var vm = QuoteViewModel()
    
    let categories = ["Motivation", "Love", "Success", "Wisdom", "Humor"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        CategoryButton(title: "All", isSelected: vm.selectedCategory == nil) {
                            vm.selectedCategory = nil
                        }
                        ForEach(categories, id: \.self) { category in
                            CategoryButton(title: category, isSelected: vm.selectedCategory == category) {
                                vm.selectedCategory = category
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                
                // Quote of the Day Section
                if let dailyQuote = vm.quoteOfTheDay {
                    VStack(alignment: .center) {
                        Text("QUOTE OF THE DAY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        QuoteCard(quote: dailyQuote, isFavorite: vm.favorites.contains(dailyQuote.id)) {
                            vm.toggleFavorite(quote: dailyQuote)
                        }
                        .contextMenu {
                            Button {
                                vm.toggleFavorite(quote: dailyQuote)
                            } label: {
                                Label(vm.favorites.contains(dailyQuote.id) ? "Unfavorite" : "Favorite", systemImage: "heart")
                            }
                            
                            // 👇 NEW: Add to Collection Button
                            Button {
                                quoteForCollection = dailyQuote
                            } label: {
                                Label("Add to Collection", systemImage: "folder.badge.plus")
                            }
                            
                            Button {
                                quoteToShare = dailyQuote
                            } label: {
                                Label("Share Quote", systemImage: "square.and.arrow.up")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    }
                    .padding(.top)
                }
                
                // Quote List
                if vm.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    List {
                        ForEach(vm.filteredQuotes) { quote in
                            QuoteCard(quote: quote, isFavorite: vm.favorites.contains(quote.id)) {
                                vm.toggleFavorite(quote: quote)
                            }
                            .contextMenu {
                                Button {
                                    vm.toggleFavorite(quote: quote)
                                } label: {
                                    Label(vm.favorites.contains(quote.id) ? "Unfavorite" : "Favorite", systemImage: "heart")
                                }
                                
                                // 👇 NEW: Add to Collection Button (For List Items)
                                Button {
                                    quoteForCollection = quote
                                } label: {
                                    Label("Add to Collection", systemImage: "folder.badge.plus")
                                }
                                
                                Button {
                                    quoteToShare = quote
                                } label: {
                                    Label("Share Quote", systemImage: "square.and.arrow.up")
                                }
                                
                                Button(role: .destructive){
                                    vm.delete(quote: quote)
                                } label : {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    vm.delete(quote: quote)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            
                        }
                        
                    }
                    .listStyle(.plain)
                    .refreshable {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        await vm.fetchData()
                    }
                }
            }
            .navigationTitle("Daily Wisdom")
            .searchable(text: $vm.searchText, prompt: "Search quotes or authors...")
            
            
            
            // Sheet 1: Export/Share
            .sheet(item: $quoteToShare) { quote in
                QuoteExportView(quote: quote)
            }
            
            // 👇 Sheet 2: Add to Collection Picker
            .sheet(item: $quoteForCollection) { quote in
                AddToCollectionView(quote: quote)
            }
        }
    }
}


// ... (The rest of your file: CategoryButton, QuoteCard, and #Preview remain exactly the same)

// Subview: Category Button
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

// Subview: The Quote Card UI
struct QuoteCard: View {
    let quote: Quote
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    @AppStorage("fontSize") private var fontSize: Double = 20.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: "quote.opening")
                    .font(.largeTitle)
                    .foregroundColor(.blue.opacity(0.3))
                Spacer()
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                        .font(.title3)
                }
            }
            
            Text(quote.content)
                .font(.system(size: fontSize))
                .fontWeight(.medium)
                .fontDesign(.serif)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            HStack {
                Spacer()
                Text("- " + quote.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
}
