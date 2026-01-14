//
//  Models.swift
//  QuoteVault
//
//  Created by Kanika Arora on 13/01/26.
//

import Foundation


struct Quote: Identifiable, Codable, Hashable {
    let id: UUID
    let content: String
    let author: String
    let category: String
    // We might not always get created_at if we select partial data, so make it optional
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, content, author, category
        case createdAt = "created_at"
    }
}

struct Profile: Codable {
    let id: UUID
    let email: String?
    let fullName: String?
    let avatarUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
    }
}
