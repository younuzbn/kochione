//
//  UserProfile.swift
//  Kochi One
//
//  Created on 27/11/25.
//

import Foundation

struct UserProfile: Codable, Identifiable {
    let id: String
    let deviceId: String
    var fullName: String
    var profileImage: ProfileImage?
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case deviceId
        case fullName
        case profileImage
        case isActive
        case createdAt
        case updatedAt
    }
}

struct ProfileImage: Codable {
    let url: String?
    let key: String?
    let originalName: String?
    let size: Int?
    let uploadedAt: String?
}

struct UserProfileResponse: Codable {
    let status: String
    let message: String?
    let data: UserProfileData
}

struct UserProfileData: Codable {
    let profile: UserProfile
}

struct APIError: Codable, Error {
    let status: String
    let message: String
    let errors: [ValidationError]?
}

struct ValidationError: Codable {
    let field: String?
    let message: String
    let value: String?
}

