//
//  CollectionDetailView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 14/01/26.
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: QuoteCollection
    @ObservedObject var vm: CollectionViewModel
    
    // State for sharing
    @State private var quoteToShare: Quote?
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).ignoresSafeArea()
            
            if vm.isLoading {
                ProgressView()
            } else if vm.selectedCollectionQuotes.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "quote.bubble")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No quotes here yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(vm.selectedCollectionQuotes) { quote in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(quote.content)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(4)
                            
                            Text("- \(quote.author)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .contextMenu {
                            Button {
                                quoteToShare = quote
                            } label: {
                                Label("Share Quote", systemImage: "square.and.arrow.up")
                            }
                            
                            // Optional: Add Delete to context menu as well
                            Button(role: .destructive) {
                                if let index = vm.selectedCollectionQuotes.firstIndex(where: { $0.id == quote.id }) {
                                    vm.removeQuoteFromCollection(at: IndexSet(integer: index), collectionId: collection.id)
                                }
                            } label: {
                                Label("Remove from Collection", systemImage: "trash")
                            }
                        }
                    }
                    // 👇 1. ADDED: This enables swipe-to-delete
                    .onDelete(perform: deleteQuote)
                }
            }
        }
        .navigationTitle(collection.name)
        // 👇 2. ADDED: This adds the "Edit" button to the top right
        .toolbar {
            EditButton()
        }
        .onAppear {
            // Fetch the quotes for this specific folder when the screen opens
            Task {
                await vm.fetchQuotes(for: collection.id)
            }
        }
        // Connect the Share Sheet we built earlier
        .sheet(item: $quoteToShare) { quote in
            QuoteExportView(quote: quote)
        }
    }
    
    // 👇 3. ADDED: Helper function to connect View to ViewModel
    func deleteQuote(at offsets: IndexSet) {
        vm.removeQuoteFromCollection(at: offsets, collectionId: collection.id)
    }
}
