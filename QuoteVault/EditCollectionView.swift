//
//  EditCollectionView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 14/01/26.
//

import SwiftUI

struct EditCollectionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: CollectionViewModel
    
    var collectionToEdit: QuoteCollection?
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "folder.fill"
    
    // Loading state to prevent double-tapping
    @State private var isSaving = false
    
    let icons = [
        "folder.fill", "list.bullet", "bookmark.fill", "star.fill", "heart.fill",
        "flame.fill", "bolt.fill", "lightbulb.fill", "tag.fill", "doc.text.fill",
        "graduationcap.fill", "briefcase.fill", "airplane", "cart.fill", "gift.fill",
        "person.fill", "building.columns.fill", "music.note", "camera.fill", "gamecontroller.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Collection Name", text: $name)
                        .submitLabel(.done)
                    
                    HStack {
                        Spacer()
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                            )
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section("Choose Icon") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 20) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                .foregroundColor(selectedIcon == icon ? .blue : .gray)
                                .clipShape(Circle())
                                .onTapGesture {
                                    withAnimation { selectedIcon = icon }
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                if let collection = collectionToEdit {
                    Section {
                        Button(role: .destructive) {
                            Task {
                                await vm.deleteCollection(id: collection.id)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Collection")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(collectionToEdit == nil ? "New Collection" : "Edit Collection")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(isSaving) // Prevent closing while saving
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        // 👇 FIX: Wait for save to finish before closing
                        Task {
                            isSaving = true
                            await save()
                            isSaving = false
                            dismiss()
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("Done")
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .onAppear {
                if let collection = collectionToEdit {
                    name = collection.name
                    selectedIcon = collection.icon ?? "folder.fill"
                }
            }
        }
    }
    
    // 👇 FIX: Make this function async
    func save() async {
        if let collection = collectionToEdit {
            await vm.updateCollection(id: collection.id, name: name, icon: selectedIcon)
        } else {
            await vm.createCollection(name: name, icon: selectedIcon)
        }
    }
}

#Preview {
    EditCollectionView(vm: CollectionViewModel())
}
