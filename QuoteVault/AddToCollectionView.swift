//
//  AddToCollectionView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 14/01/26.
//

import SwiftUI

struct AddToCollectionView: View {
    let quote: Quote
    @Environment(\.dismiss) var dismiss
    
    // We create a dedicated VM here to fetch the list of collections
    @StateObject private var vm = CollectionViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                if vm.isLoading && vm.collections.isEmpty {
                    ProgressView()
                } else if vm.collections.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "folder.badge.plus")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No collections found.")
                        Text("Create one in the Collections tab first.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(vm.collections) { collection in
                            Button {
                                saveQuote(to: collection)
                            } label: {
                                HStack {
                                    // Use the custom icon with a fallback
                                    Image(systemName: collection.icon ?? "folder.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    Text(collection.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                Task { await vm.fetchCollections() }
            }
        }
        // Makes it look like a nice half-sheet
        .presentationDetents([.medium, .large])
    }
    
    func saveQuote(to collection: QuoteCollection) {
        Task {
            // Call the function we already wrote in CollectionViewModel
            await vm.addQuoteToCollection(quoteId: quote.id, collectionId: collection.id)
            dismiss()
        }
    }
}
