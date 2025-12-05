//
//  ExplorePost.swift
//  Kochi One
//
//  Created on 27/11/25.
//

import Foundation

// MARK: - ExplorePost Model
struct ExplorePost: Codable, Identifiable {
    let id: String              // "_id" from API
    let title: String
    let description: String
    let postType: Int
    let listPosition: Int
    let media: [MediaItem]
    let contactInfo: ContactInfo?  // ✅ Now optional
    let isActive: Bool
    let views: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title, description, postType, listPosition
        case media, contactInfo, isActive, views
        case createdAt, updatedAt
    }
}

// MARK: - MediaItem Model
struct MediaItem: Codable {
    let url: String
    let key: String
    let type: String           // "image" or "video"
    let position: Int
    let originalName: String?
    let size: Int?
    let uploadedAt: String?
}

// MARK: - ContactInfo Model
struct ContactInfo: Codable {
    let type: String           // "contact" or "button"
    
    // For type: "contact"
    let mobile: String?
    let email: String?
    let website: String?
    let location: Location?
    
    // For type: "button"
    let buttonLabel: String?
    let buttonIcon: String?
    let buttonUrl: String?
}

// MARK: - Location Model
struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

// MARK: - API Response Models
struct ExplorePostsResponse: Codable {
    let status: String
    let data: ExplorePostsData
}

struct ExplorePostsData: Codable {
    let posts: [ExplorePost]
    let pagination: Pagination?
}

struct Pagination: Codable {
    let currentPage: Int
    let totalPages: Int
    let totalPosts: Int
    let hasNext: Bool
    let hasPrev: Bool
}

struct ExplorePostResponse: Codable {
    let status: String
    let data: ExplorePostData
}

struct ExplorePostData: Codable {
    let post: ExplorePost
}

