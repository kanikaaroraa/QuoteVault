//
//  QuoteWidget.swift
//  QuoteWidget
//
//  Created by Kanika Arora on 13/01/26.
//

import WidgetKit
import SwiftUI

// 1. The Data Model for the Widget
struct WidgetEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
}

// 2. The Provider (Tells the widget what to show)
struct Provider: TimelineProvider {
    
    // A small hardcoded list for the widget to ensure it always has data for the demo
    let sampleQuotes = [
        ("The only way to do great work is to love what you do.", "Steve Jobs"),
        ("Believe you can and you are halfway there.", "Theodore Roosevelt"),
        ("Act as if what you do makes a difference. It does.", "William James"),
        ("Success is not final, failure is not fatal.", "Winston Churchill"),
        ("Happiness depends upon ourselves.", "Aristotle")
    ]
    
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), quote: "Loading wisdom...", author: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let entry = WidgetEntry(date: Date(), quote: sampleQuotes[0].0, author: sampleQuotes[0].1)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        var entries: [WidgetEntry] = []
        let currentDate = Date()
        
        // Create a timeline for the next 5 hours (updates every hour)
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            // Pick a random quote for the update
            let randomQuote = sampleQuotes.randomElement()!
            
            let entry = WidgetEntry(
                date: entryDate,
                quote: randomQuote.0,
                author: randomQuote.1
            )
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// 3. The UI View
struct QuoteWidgetEntryView : View {
    var entry: Provider.Entry
    
    // Solid background color
    let plainBackgroundColor = Color(red: 0.12, green: 0.12, blue: 0.18)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) { // Reduced spacing from 10 to 4
            Image(systemName: "quote.opening")
                .foregroundColor(.white.opacity(0.6))
                .font(.caption) // Made icon smaller
            
            Text(entry.quote)
                .font(.system(size: 15, weight: .medium, design: .default))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.5) // Allows text to shrink down to 50% if needed
                .layoutPriority(1) // Tells iOS: "This text is the most important thing"
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Spacer allows text to push author down, but will collapse if text is long
            Spacer(minLength: 0)
            
            Text("- \(entry.author)")
                .font(.system(size: 10)) // Smaller author font
                .foregroundColor(.white.opacity(0.7))
                .italic()
                .lineLimit(1) // Force author to 1 line
        }
        .padding(12) // Reduced padding slightly to give content more room
        .containerBackground(plainBackgroundColor, for: .widget)
    }
}
// 4. The Widget Configuration
@main
struct QuoteWidget: Widget {
    let kind: String = "QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Wisdom")
        .description("Get your daily dose of motivation.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    QuoteWidget()
} timeline: {
    WidgetEntry(date: Date(), quote: "Believe you can and you are halfway there.", author: "Theodore Roosevelt")
    WidgetEntry(date: Date(), quote: "The only way to do great work is to love what you do.", author: "Steve Jobs")
}
