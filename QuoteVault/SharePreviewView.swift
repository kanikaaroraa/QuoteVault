//
//  SharePreviewView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 14/01/26.
//

import SwiftUI

struct SharePreviewView: View {
    
    // 1. We use the image passed in from the parent view
    let image: UIImage
    
    @Environment(\.dismiss) var dismiss
    @State private var showSystemShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // The Preview Image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .padding(30)
                
                Spacer()
                
                // The Action Button
                Button(action: {
                    showSystemShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Now")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
            .background(Color.black.ignoresSafeArea()) // Cinema style background
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.white)
                }
            }
            // 2. The Sheet Logic
            .sheet(isPresented: $showSystemShareSheet) {
                // We pass the 'image' property directly to the helper struct
                ShareSheet(items: [image])
            }
        }
    }
}

