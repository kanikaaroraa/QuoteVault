import SwiftUI

// 1. Share Sheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = [.addToReadingList, .assignToContact, .print]
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// 2. Spotify-Style Card Generator
@MainActor
struct ShareManager {
    static func generateImage(for quote: Quote) -> UIImage {
        // Define Brand Colors (Deep Blue/Purple Gradient)
        let colorTop = Color(red: 0.1, green: 0.1, blue: 0.4)
        let colorBottom = Color(red: 0.4, green: 0.1, blue: 0.5)
        
        let renderer = ImageRenderer(content:
            ZStack {
                // Background
                LinearGradient(
                    colors: [colorTop, colorBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Icon
                    Image(systemName: "quote.opening")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.3))
                    
                    // Quote Text
                    Text(quote.content)
                        .font(.system(size: 32, weight: .heavy, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .minimumScaleFactor(0.5) // Shrinks text if it's too long
                    
                    // Author
                    Text("- \(quote.author.uppercased())")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    // Logo Footer
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                        Text("QuoteVault")
                            .font(.headline.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
                }
            }
            .frame(width: 1080, height: 1080) // High Resolution Square
        )
        
        renderer.scale = 1.0
        return renderer.uiImage ?? UIImage()
    }
}
