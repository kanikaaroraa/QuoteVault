//
//  SettingsView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//
import SwiftUI
import UserNotifications
import Supabase

struct SettingsView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    // 1. WATCH FOR CHANGES
    @AppStorage("userName") private var userName = "User" // Auto-updates name
    @State private var profileImage: UIImage? // Auto-updates image
    
    // Existing settings...
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 20.0
    @AppStorage("notificationTime") private var notificationTime = Date()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    
    @State private var showPasswordAlert = false
    @State private var newPassword = ""
    @State private var updateMessage = ""
    @State private var showUpdateResult = false
    
    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section {
                    NavigationLink(destination: ProfileView()) {
                        HStack(spacing: 15) {
                            // 2. USE THE STATE IMAGE
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 50, height: 50)
                            }
                            
                            VStack(alignment: .leading) {
                                // 2. USE THE APPSTORAGE NAME
                                Text(userName.capitalized)
                                    .font(.headline)
                                Text("Edit Profile")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Appearance Section
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                    VStack(alignment: .leading) {
                        Text("Font Size: \(Int(fontSize))")
                        Slider(value: $fontSize, in: 14...30, step: 1)
                    }
                }
                
                // Notifications Section
                Section(header: Text("Daily Inspiration")) {
                    Toggle("Enable Daily Quote", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            if newValue { requestPermission() } else { cancelNotifications() }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .onChange(of: notificationTime) { _ in scheduleNotification() }
                    }
                }
                
                // Security Section
                Section(header: Text("Security")) {
                    Button("Change Password") {
                        newPassword = ""
                        showPasswordAlert = true
                    }
                }
                
                // Account Section
                Section {
                    Button("Sign Out") {
                        authVM.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            // 3. RELOAD DATA WHEN VIEW APPEARS
            .onAppear {
                loadProfileImage()
            }
            // Alerts...
            .alert("Update Password", isPresented: $showPasswordAlert) {
                SecureField("New Password", text: $newPassword)
                Button("Update") { updatePassword() }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Status", isPresented: $showUpdateResult) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(updateMessage)
            }
        }
    }
    
    // Helper to load image from disk
    func loadProfileImage() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("profile.jpg")
        if let data = try? Data(contentsOf: url) {
            profileImage = UIImage(data: data)
        }
    }
    
    // ... (Keep your updatePassword, requestPermission, etc. functions below)
    func updatePassword() {
        Task {
            do {
                try await supabase.auth.update(user: UserAttributes(password: newPassword))
                updateMessage = "Password updated successfully!"
                showUpdateResult = true
            } catch {
                updateMessage = "Failed to update: \(error.localizedDescription)"
                showUpdateResult = true
            }
        }
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted { scheduleNotification() } else { DispatchQueue.main.async { notificationsEnabled = false } }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Wisdom"
        content.body = "Your quote of the day is waiting for you!"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyQuote", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

#Preview {
    SettingsView()
}
