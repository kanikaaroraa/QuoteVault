//
//  SettingsView.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import SwiftUI
import UserNotifications

struct SettingsView: View {
    // Persist settings automatically (Req 6)
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("fontSize") private var fontSize: Double = 20.0
    @AppStorage("notificationTime") private var notificationTime = Date()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    
    @StateObject var authVM = AuthViewModel() // To handle logout
    
    var body: some View {
        NavigationView {
            Form {
                // Section 1: Personalization
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                    
                    VStack(alignment: .leading) {
                        Text("Font Size: \(Int(fontSize))")
                        Slider(value: $fontSize, in: 14...30, step: 1)
                    }
                }
                
                // Section 2: Notifications (Req 4)
                Section(header: Text("Daily Inspiration")) {
                    Toggle("Enable Daily Quote", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            if newValue {
                                requestPermission()
                            } else {
                                cancelNotifications()
                            }
                        }
                    
                    if notificationsEnabled {
                        DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .onChange(of: notificationTime) { _ in
                                scheduleNotification() // Reschedule when time changes
                            }
                    }
                }
                
                // Section 3: Account
                Section {
                    Button("Sign Out") {
                        authVM.signOut()
                        // Note: In a real app, you'd reset the root view.
                        // For this assignment, the AuthViewModel state change might need
                        // to be passed up or we force a restart.
                        // A simple way is to use the shared AuthViewModel.
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    // MARK: - Notification Logic
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                scheduleNotification()
            } else {
                DispatchQueue.main.async { notificationsEnabled = false }
            }
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
