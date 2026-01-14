//
//  CollectionViewModel.swift
//  QuoteVault
//
//  Created by Kanika Arora on 14/01/26.
//

import SwiftUI
import Supabase
import Combine

// NOTE: Ensure struct QuoteCollection is ONLY defined in Models.swift
// Do NOT define it here again.

struct CollectionItem: Codable {
    let quote: Quote
}

@MainActor
class CollectionViewModel: ObservableObject {
    @Published var collections: [QuoteCollection] = []
    @Published var selectedCollectionQuotes: [Quote] = []
    @Published var isLoading = false
    
    // MARK: - FETCH
    func fetchCollections() async {
        do {
            let userId = supabase.auth.currentUser?.id
            guard userId != nil else { return }
            
            self.collections = try await supabase
                .from("user_collections")
                .select()
                .order("created_at", ascending: true) // Keep order consistent
                .execute()
                .value
        } catch {
            print("Error fetching collections: \(error)")
        }
    }
    
    // MARK: - CREATE
    func createCollection(name: String, icon: String) async {
        guard let userId = supabase.auth.currentUser?.id else { return }
        
        let newCollection = [
            "user_id": userId.uuidString,
            "name": name,
            "icon": icon
        ]
        
        do {
            try await supabase.from("user_collections").insert(newCollection).execute()
            await fetchCollections()
        } catch {
            print("Error creating collection: \(error)")
        }
    }
    
    // MARK: - UPDATE (The Fix for Renaming)
    func updateCollection(id: UUID, name: String, icon: String) async {
        // 1. OPTIMISTIC UPDATE: Update UI immediately
        if let index = collections.firstIndex(where: { $0.id == id }) {
            // We replace the struct in the array with a new one
            // This works even if 'name' is a 'let' constant in the Model
            let updatedCollection = QuoteCollection(id: id, name: name, icon: icon)
            collections[index] = updatedCollection
        }
        
        // 2. DATABASE UPDATE
        do {
            try await supabase
                .from("user_collections")
                .update([
                    "name": name,
                    "icon": icon
                ])
                .eq("id", value: id.uuidString)
                .execute()
            
            print("✅ Database updated successfully")
        } catch {
            print("❌ Database update failed: \(error)")
            // If DB failed, revert UI by refetching
            await fetchCollections()
        }
    }
    
    // MARK: - DELETE
    func deleteCollection(id: UUID) async {
        withAnimation {
            collections.removeAll { $0.id == id }
        }
        
        do {
            try await supabase
                .from("user_collections")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
        } catch {
            print("Error deleting collection: \(error)")
            await fetchCollections()
        }
    }
    
    // ... (Keep your addQuoteToCollection and fetchQuotes functions here) ...
    // MARK: - ADD QUOTE TO COLLECTION
    func addQuoteToCollection(quoteId: UUID, collectionId: UUID) async {
        let newItem = [
            "collection_id": collectionId.uuidString,
            "quote_id": quoteId.uuidString
        ]
        
        do {
            try await supabase.from("collection_items").insert(newItem).execute()
            print("Quote added successfully!")
        } catch {
            print("Error adding quote: \(error)")
        }
    }
    
    // MARK: - FETCH QUOTES INSIDE A COLLECTION
    func fetchQuotes(for collectionId: UUID) async {
        self.isLoading = true
        self.selectedCollectionQuotes = []
        
        do {
            let response: [CollectionItem] = try await supabase
                .from("collection_items")
                .select("quote:quotes(*)")
                .eq("collection_id", value: collectionId)
                .execute()
                .value
            
            self.selectedCollectionQuotes = response.map { $0.quote }
            self.isLoading = false
        } catch {
            print("Error fetching items: \(error)")
            self.isLoading = false
        }
    }


    func removeQuoteFromCollection(at offsets: IndexSet, collectionId: UUID) {
        // 1. Identify which quotes are being deleted based on the swipe
        let quotesToRemove = offsets.map { selectedCollectionQuotes[$0] }
        
        // 2. Remove them from the UI list immediately
        selectedCollectionQuotes.remove(atOffsets: offsets)
        
        // 3. TODO: Add your database logic here to permanently remove
        // the relationship between these quotes and the collection.
        // Example: dbService.remove(quotes: quotesToRemove, from: collectionId)
    }
}
