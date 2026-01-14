//
//  AuthViewModel.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    init() {
        checkSession()
    }
    
    func checkSession() {
        Task {
            do {
                _ = try await supabase.auth.session
                self.isAuthenticated = true
            } catch {
                self.isAuthenticated = false
            }
        }
    }
    
    func signUp(email: String, pass: String) async {
        isLoading = true
        errorMessage = ""
        do {
            _ = try await supabase.auth.signUp(email: email, password: pass)
            // Supabase defaults to "confirm email" flow.
            // If you disabled email confirm in Supabase dashboard, this logs them in immediately.
            errorMessage = "Account created! Please log in (check email if confirmation is on)."
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func signIn(email: String, pass: String) async {
        isLoading = true
        errorMessage = ""
        do {
            _ = try await supabase.auth.signIn(email: email, password: pass)
            isAuthenticated = true
            isLoading = false
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func signOut() {
        Task {
            try? await supabase.auth.signOut()
            isAuthenticated = false
        }
    }
    // Add this inside AuthViewModel class
    func sendPasswordReset(email: String) async {
        isLoading = true
        errorMessage = ""
        do {
            // This sends a reset email to the user
            try await supabase.auth.resetPasswordForEmail(email)
            errorMessage = "Check your email for the password reset link."
            isLoading = false
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
