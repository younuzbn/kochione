//
//  PublicUserProfileService.swift
//  Kochi One
//
//  Created on 27/11/25.
//

import Foundation
import UIKit

class PublicUserProfileService {
    static let shared = PublicUserProfileService()
    
    private let baseURL = "https://codecastle.store/api/public-users"
    
    private init() {}
    
    // MARK: - Get Profile
    func getProfile(deviceId: String) async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/\(deviceId)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            if let error = try? JSONDecoder().decode(APIError.self, from: data) {
                throw error
            }
            throw URLError(.badServerResponse)
        }
        
        let profileResponse = try JSONDecoder().decode(UserProfileResponse.self, from: data)
        return profileResponse.data.profile
    }
    
    // MARK: - Create Profile
    func createProfile(deviceId: String, fullName: String, profileImage: UIImage?) async throws -> UserProfile {
        guard let url = URL(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add deviceId
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"deviceId\"\r\n\r\n".data(using: .utf8)!)
        body.append(deviceId.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add fullName
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"fullName\"\r\n\r\n".data(using: .utf8)!)
        body.append(fullName.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add profile image if provided
        if let image = profileImage,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"profileImage\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 201 else {
            if let error = try? JSONDecoder().decode(APIError.self, from: data) {
                throw error
            }
            throw URLError(.badServerResponse)
        }
        
        let profileResponse = try JSONDecoder().decode(UserProfileResponse.self, from: data)
        return profileResponse.data.profile
    }
    
    // MARK: - Update Profile
    func updateProfile(deviceId: String, fullName: String?, profileImage: UIImage?) async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/\(deviceId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // If no image, use JSON
        if profileImage == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var body: [String: Any] = [:]
            if let fullName = fullName {
                body["fullName"] = fullName
            }
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } else {
            // Use multipart/form-data for image upload
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            var body = Data()
            
            // Add fullName if provided
            if let fullName = fullName {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"fullName\"\r\n\r\n".data(using: .utf8)!)
                body.append(fullName.data(using: .utf8)!)
                body.append("\r\n".data(using: .utf8)!)
            }
            
            // Add profile image
            if let image = profileImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"profileImage\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
            
            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            if let error = try? JSONDecoder().decode(APIError.self, from: data) {
                throw error
            }
            throw URLError(.badServerResponse)
        }
        
        let profileResponse = try JSONDecoder().decode(UserProfileResponse.self, from: data)
        return profileResponse.data.profile
    }
    
    // MARK: - Delete Profile Image
    func deleteProfileImage(deviceId: String) async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/\(deviceId)/profile-image") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            if let error = try? JSONDecoder().decode(APIError.self, from: data) {
                throw error
            }
            throw URLError(.badServerResponse)
        }
        
        let profileResponse = try JSONDecoder().decode(UserProfileResponse.self, from: data)
        return profileResponse.data.profile
    }
    
    // MARK: - Delete Profile
    func deleteProfile(deviceId: String) async throws {
        guard let url = URL(string: "\(baseURL)/\(deviceId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
    }
    
    // MARK: - Load Image from URL
    func loadImage(from urlString: String?) async -> UIImage? {
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
}

