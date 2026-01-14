//
//  CollectionsView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 14/01/26.
//

import SwiftUI

struct CollectionsView: View {
    @StateObject var vm = CollectionViewModel()
    
    // 👇 NEW: Sheet State (Replaces Alerts)
    @State private var showEditSheet = false
    @State private var collectionToEdit: QuoteCollection? // Tracks which one we are editing
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if vm.isLoading && vm.collections.isEmpty {
                    ProgressView()
                } else if vm.collections.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No Collections Yet")
                            .font(.headline)
                    }
                } else {
                    List {
                        ForEach(vm.collections, id: \.id) { collection in
                            NavigationLink(destination: CollectionDetailView(collection: collection, vm: vm)) {
                                HStack {
                                    // 👇 USE DYNAMIC ICON HERE
                                    Image(systemName: (collection.icon?.isEmpty == false ? collection.icon! : "folder"))
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                        .frame(width: 30) // Fixed width aligns text nicely
                                    
                                    Text(collection.name)
                                        .font(.headline)
                                        .padding(.leading, 5)
                                }
                                .padding(.vertical, 8)
                            }
                            // 👇 SWIPE ACTIONS (Delete & Edit)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task { await vm.deleteCollection(id: collection.id) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    collectionToEdit = collection
                                    showEditSheet = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.indigo)
                            }
                            // 👇 CONTEXT MENU (Long Press)
                            .contextMenu {
                                Button {
                                    collectionToEdit = collection
                                    showEditSheet = true
                                } label: {
                                    Label("Edit Collection", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    Task { await vm.deleteCollection(id: collection.id) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Collections")
            .onAppear { Task { await vm.fetchCollections() } }
            .toolbar {
                // 👇 CREATE BUTTON (Opens Sheet)
                Button(action: {
                    collectionToEdit = nil // Nil means "Create New"
                    showEditSheet = true
                }) {
                    Image(systemName: "plus").fontWeight(.bold)
                }
            }
            // 👇 THE SHEET LOGIC
            .sheet(isPresented: $showEditSheet) {
                EditCollectionView(vm: vm, collectionToEdit: collectionToEdit)
            }
        }
    }
}

#Preview {
    CollectionsView()
}
