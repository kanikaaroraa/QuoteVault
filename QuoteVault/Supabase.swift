//
//  Supabase.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import Foundation
import Supabase

// MARK: - App Constants
// Ideally, store these in a Config file or Info.plist to avoid hardcoding (Requirement 8)
enum Config {
    static let supabaseUrl = URL(string: "https://aeouotvvnofjhdxlzpkm.supabase.co")!
    static let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFlb3VvdHZ2bm9mamhkeGx6cGttIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgzMDg4MTAsImV4cCI6MjA4Mzg4NDgxMH0.lS8cWEDhEiQReFwRLkIBmMzeQs37snazVXmWIhdOMU0"
}

// Global client variable (Simplest for this deadline)
let supabase = SupabaseClient(
    supabaseURL: Config.supabaseUrl,
    supabaseKey: Config.supabaseKey
)
