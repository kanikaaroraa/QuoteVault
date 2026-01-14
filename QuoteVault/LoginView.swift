//
//  LoginView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var vm: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    // For password reset
    @State private var showResetAlert = false
    @State private var resetEmail = ""
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Quote Vault")
                    .font(.system(size: 50, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding(.bottom, 20)
                
                VStack(spacing: 15) {
                    // Email Field with new style
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .modifier(CustomOvalFieldModifier())
                    
                    // Password Field with new style
                    SecureField("Password", text: $password)
                        .modifier(CustomOvalFieldModifier())
                    
                    // Forgot Password Button (Untouched)
                    HStack {
                        Spacer()
                        Button("Forgot Password?") {
                            showResetAlert = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.trailing, 5)
                    }
                }
                // Removed the old container background/shadow here
                
                if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Sign In Button
                                Button(action: {
                                    Task {
                                        if isSignUp {
                                            await vm.signUp(email: email, pass: password)
                                        } else {
                                            await vm.signIn(email: email, pass: password)
                                        }
                                    }
                                }) {
                                    if vm.isLoading {
                                        ProgressView()
                                            .tint(colorScheme == .light ? .white : .black) // Spinner matches text
                                    } else {
                                        Text(isSignUp ? "Create Account" : "Sign In")
                                            .bold()
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            // 👇 DESIGN CHANGE:
                                            // Adaptive Background: Black in Light Mode, White in Dark Mode
                                            .background(Color.primary)
                                            // Adaptive Text: White in Light Mode, Black in Dark Mode
                                            .foregroundColor(colorScheme == .light ? .white : .black)
                                            .cornerRadius(25) // Matches the Oval fields
                                    }
                                }
                                .disabled(email.isEmpty || password.isEmpty)
                                .padding(.top, 10)
                
                // Sign Up Toggle (Untouched)
                Button(action: { isSignUp.toggle() }) {
                    Text(isSignUp ? "Already have an account? Log In" : "New here? Sign Up")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            .padding()
            
            // Alert logic
            .alert("Reset Password", isPresented: $showResetAlert) {
                TextField("Enter your email", text: $resetEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                Button("Send Link") {
                    Task { await vm.sendPasswordReset(email: resetEmail) }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("We will send a password reset link to your email.")
            }
        }
    }
}

// 👇 The new custom style helper
struct CustomOvalFieldModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                // Use White for Light mode, Dark Gray for Dark mode
                colorScheme == .light ? Color.white : Color(UIColor.tertiarySystemBackground)
            )
            .cornerRadius(25) // Makes it oval
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2) // Light shadow
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}


