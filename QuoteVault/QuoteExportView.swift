//
//  QuoteExportView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import SwiftUI

struct QuoteExportView: View {
    let quote: Quote
    @Environment(\.dismiss) var dismiss
    
    // Req 5: At least 3 different styles
    enum CardTheme: String, CaseIterable, Identifiable {
        case classic = "Classic" // White clean
        case midnight = "Midnight" // Dark gradient
        case sunset = "Sunset" // Orange gradient
        var id: String { self.rawValue }
    }
    
    @State private var selectedTheme: CardTheme = .classic
    @State private var showSystemShareSheet = false
    @State private var generatedImage: UIImage?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // 1. The Preview Card
                cardView
                    .shadow(radius: 10)
                
                // 2. Theme Selector
                Picker("Theme", selection: $selectedTheme) {
                    ForEach(CardTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Spacer()
                
                // 3. Share Button
                Button(action: exportImage) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Quote")
                    }
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Share Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            // 4. The actual Share Sheet Popup
            .sheet(isPresented: $showSystemShareSheet) {
                if let image = generatedImage {
                    ShareSheet(items: [image, quote.content])
                }
            }
        }
    }
    
    // The actual design of the card to be exported
    var cardView: some View {
        VStack(spacing: 20) {
            Image(systemName: "quote.opening")
                .font(.largeTitle)
                .foregroundColor(themeTextColor.opacity(0.5))
            
            Text(quote.content)
                .font(.custom("Georgia", size: 24))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(themeTextColor)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("- \(quote.author)")
                .font(.headline)
                .foregroundColor(themeTextColor.opacity(0.8))
            
            Text("Quote Vault")
                .font(.caption)
                .textCase(.uppercase)
                .foregroundColor(themeTextColor.opacity(0.4))
                .padding(.top, 10)
        }
        .padding(40)
        .frame(width: 300, height: 400) // Fixed size for consistent export
        .background(themeBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(themeTextColor.opacity(0.1), lineWidth: 1)
        )
    }
    
    // Logic to render the View into an Image
    @MainActor
    func exportImage() {
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0 // High quality
        
        if let image = renderer.uiImage {
            generatedImage = image
            showSystemShareSheet = true
        }
    }
    
    // MARK: - Style Helpers
    var themeBackground: some View {
        switch selectedTheme {
        case .classic: return AnyView(Color.white)
        case .midnight: return AnyView(
            LinearGradient(colors: [Color.black, Color(uiColor: .darkGray)], startPoint: .top, endPoint: .bottom)
        )
        case .sunset: return AnyView(
            LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        }
    }
    
    var themeTextColor: Color {
        switch selectedTheme {
        case .classic: return .black
        case .midnight, .sunset: return .white
        }
    }
}

