//
//  ProfileView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 14/01/26.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    // Save name automatically to local storage
    @AppStorage("userName") private var userName = "User"
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var profileImage: UIImage? = nil
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack(spacing: 20) {
                        // 1. The Avatar Image
                        ZStack(alignment: .bottomTrailing) {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                            }
                            
                            // Edit Icon
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                                .background(Color.white.clipShape(Circle()))
                        }
                        // 2. The Photo Picker Trigger
                        .overlay {
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Color.clear.frame(width: 120, height: 120)
                            }
                        }
                        
                        Text("Tap to edit photo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical)
            }
            
            // 3. Name Field
            Section(header: Text("Profile Info")) {
                TextField("Your Name", text: $userName)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                
            }
        }
        .navigationTitle("Edit Profile")
        .onAppear(perform: loadProfileImage)
        // 4. Handle Image Selection
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = uiImage
                    saveProfileImage(data: data)
                }
            }
        }
    }
    
    // MARK: - File System Helpers
    // We save the image to the phone's Documents directory so it persists
    func saveProfileImage(data: Data) {
        let url = getDocumentsDirectory().appendingPathComponent("profile.jpg")
        try? data.write(to: url)
    }
    
    func loadProfileImage() {
        let url = getDocumentsDirectory().appendingPathComponent("profile.jpg")
        if let data = try? Data(contentsOf: url), let uiImage = UIImage(data: data) {
            profileImage = uiImage
        }
    }
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}

