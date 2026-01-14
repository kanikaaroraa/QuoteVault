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
    
    // 1️⃣ State to track the selected theme
    @State private var selectedTheme: Theme = .black
    
    // 2️⃣ Define the available themes and their properties
    enum Theme: String, CaseIterable, Identifiable {
        case black
        case white
        case gradient
        
        var id: String { self.rawValue }
        
        var textColor: Color {
            switch self {
            case .black, .gradient: return .white
            case .white: return .black
            }
        }
        
        var accentColor: Color {
            switch self {
            case .black: return .white.opacity(0.5)
            case .white: return .blue.opacity(0.6)
            case .gradient: return .white.opacity(0.7)
            }
        }
        
        // Using @ViewBuilder allows us to return different types of views (Color vs LinearGradient)
        @ViewBuilder var backgroundView: some View {
            switch self {
            case .black:
                Color.black
            case .white:
                Color.white
            case .gradient:
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.5), Color(red: 0.5, green: 0.1, blue: 0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 3️⃣ Theme Selector UI
                    themeSelector
                        .padding(.top)
                    
                    Spacer()
                    
                    // The Card itself
                    cardView
                        // Add a subtle border for the white card so it pops against the gray background
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.2), lineWidth: selectedTheme == .white ? 1 : 0)
                        )
                        .shadow(radius: 10)
                    
                    Spacer()
                    
                    // Share Button
                    Button(action: {
                        // Tiny delay to ensure smooth animation before capturing
                        Task {
                            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
                            exportAndShare()
                        }
                    }) {
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
            }
            .navigationTitle("Share Quote")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Theme Selector Subview
    var themeSelector: some View {
        HStack(spacing: 20) {
            ForEach(Theme.allCases) { theme in
                Button {
                    withAnimation {
                        selectedTheme = theme
                    }
                } label: {
                    // Create circles representing the themes
                    ZStack {
                        theme.backgroundView
                            .clipShape(Circle())
                            .frame(width: 44, height: 44)
                        
                        // Add a ring around the selected one
                        if selectedTheme == theme {
                            Circle()
                                .stroke(Color.blue, lineWidth: 3)
                                .frame(width: 52, height: 52)
                        }
                        
                        // Add a faint border to the white circle so it's visible
                        if theme == .white {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(30)
    }
    
    // MARK: - The Dynamic Card Design
    var cardView: some View {
        VStack(spacing: 20) {
            Image(systemName: "quote.opening")
                .font(.largeTitle)
                // Use the dynamic accent color
                .foregroundColor(selectedTheme.accentColor)
            
            Text(quote.content)
                .font(.custom("Georgia", size: 24))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                // Use the dynamic text color
                .foregroundColor(selectedTheme.textColor)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("- \(quote.author)")
                .font(.headline)
                // Use the dynamic text color with some opacity
                .foregroundColor(selectedTheme.textColor.opacity(0.8))
            
            Text("Quote Vault")
                .font(.caption)
                .textCase(.uppercase)
                .foregroundColor(selectedTheme.textColor.opacity(0.5))
                .padding(.top, 10)
        }
        .padding(40)
        .frame(width: 300, height: 400)
        // 4️⃣ Apply the dynamic background view from the theme enum
        .background(selectedTheme.backgroundView)
        .cornerRadius(20)
    }
    
    // MARK: - Export & Share Logic
    @MainActor
    func exportAndShare() {
        // The renderer will now capture the card exactly as it looks with the selected theme
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = UIScreen.main.scale
        
        if let image = renderer.uiImage {
            presentShareSheet(items: [image, quote.content])
        }
    }
    
    // MARK: - The "Silver Bullet" Fix (Keep this existing code)
    func presentShareSheet(items: [Any]) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            var topController = rootVC
            while let presented = topController.presentedViewController {
                topController = presented
            }
            
            topController.present(activityVC, animated: true)
        }
    }
}
