//
//  README.md
//  QuoteVault
//
//  Created by Kanika Arora on 14/01/26.
//


# Quote Vault 🏛️

**Quote Vault** is a modern, elegant iOS application built with **SwiftUI** designed to help users discover, collect, and share daily wisdom. It features a robust collection system backed by **Supabase**, offering a seamless "Optimistic UI" experience where actions feel instant while syncing securely to the cloud.

## 📱 Features

### 🔍 Discovery & Inspiration
- **Daily Wisdom:** A curated "Quote of the Day" greeted upon launch.
- **Smart Filtering:** Browse quotes by categories: *Motivation, Love, Success, Wisdom, Humor*.
- **Search:** Instant search functionality to find specific quotes or authors.
- **Custom UX:** Engineered a smooth, delayed pull-to-refresh animation for a premium app feel.

### 📂 Collection Management (Supabase)
- **Custom Collections:** Create personal folders (e.g., "Gym Motivation", "Life Lessons") with custom icons.
- **Cloud Sync:** All collections are persisted remotely using **Supabase (PostgreSQL)**.
- **Swipe-to-Delete:** Implemented complex logic to handle deletions:
  - **UI First:** Removes item immediately from the screen for responsiveness.
  - **Database Background Task:** Asynchronously cleans up relationships in the database to ensure data integrity.
- **Edit Mode:** Bulk management of quotes within collections.

### 🎨 Share Studio
- **Export to Image:** Turn any quote into a high-quality image card using `ImageRenderer`.
- **Theme Selector:** Choose from three distinct styles before sharing:
  - ⚫ **Midnight:** Sleek black background with white text.
  - ⚪ **Classic:** Clean white background with a subtle border.
  - 🌈 **Aura:** A vibrant gradient background.
- **Native Integration:** Bypasses standard sheet limitations to present the native iOS Share Sheet directly.

## 🛠 Tech Stack

- **Language:** Swift 5
- **Framework:** SwiftUI
- **Architecture:** MVVM (Model-View-ViewModel)
- **Backend:** Supabase (PostgreSQL, Auth, Database)
- **Concurrency:** Swift `async`/`await` & `Task`
- **Storage:** `UserDefaults` (Local Preferences) & Remote SQL

## 🏗️ Architecture

The app follows a clean MVVM pattern to separate business logic from the UI.

### ViewModels
* **`QuoteViewModel`**: Handles fetching local quote data, filtering logic, and the "Deleted Items" trash persistence using `UserDefaults`.
* **`CollectionViewModel`**: Manages CRUD operations with Supabase. It implements **Optimistic UI** updates to ensure the interface never freezes while waiting for network requests.

### Views
* **`HomeView`**: The main dashboard featuring horizontal category scrollers and the quote feed.
* **`CollectionDetailView`**: A drill-down view for specific folders, featuring custom swipe actions and context menus.
* **`QuoteExportView`**: A dedicated studio view for customizing and rendering quote cards.

## 🚀 Setup & Installation

### 1. Prerequisites
- Xcode 15+
- iOS 16.0+
- A [Supabase](https://supabase.com) account.

### 2. Installation
1. Clone the repository:
   ```bash
   git clone [https://github.com/yourusername/QuoteVault.git](https://github.com/yourusername/QuoteVault.git)



1.Open QuoteVault.xcodeproj in Xcode.
2. Add the Supabase Swift dependency via Swift Package Manager.

3. Backend Configurations(SQL)
To make the Collections feature work, run the following SQL in your Supabase SQL Editor:

-- 1. Create table for User Collections
create table user_collections (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  name text not null,
  icon text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. Create table for linking Quotes to Collections
create table collection_items (
  id uuid default uuid_generate_v4() primary key,
  collection_id uuid references user_collections on delete cascade not null,
  quote_id uuid not null, 
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Enable RLS (Row Level Security)
alter table user_collections enable row level security;
alter table collection_items enable row level security;

-- Policy: Users can only see/edit their own data
create policy "Users manage their own collections" on user_collections
  using (auth.uid() = user_id);
  
  
4. Environment Variables
Create a Secrets.swift file (or similar) to store your keys:

let SUPABASE_URL = "[https://your-project-id.supabase.co](https://your-project-id.supabase.co)"
let SUPABASE_ANON_KEY = "your-anon-key-here"


Kanika Arora: iOS Developer
