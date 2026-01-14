//
//  LoginView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import SwiftUI

struct LoginView: View {
    @StateObject var vm = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    var body: some View {
        if vm.isAuthenticated {
            // Once logged in, we will show the Main App
            MainView()
                .transition(.opacity)
        } else {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Quote Vault")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundColor(.primary)
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    if !vm.errorMessage.isEmpty {
                        Text(vm.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
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
                        } else {
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                    
                    Button(action: { isSignUp.toggle() }) {
                        Text(isSignUp ? "Already have an account? Log In" : "New here? Sign Up")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    LoginView()
}
