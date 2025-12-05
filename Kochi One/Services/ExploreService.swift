//
//  ExploreService.swift
//  Kochi One
//
//  Created on 27/11/25.
//

import Foundation

class ExploreService {
    static let shared = ExploreService()
    
    // Base URL for explore API - update to match your server
    // For local development: "http://localhost:3000/api/explore"
    // For production: "https://codecastle.store/api/explore"
    private let baseURL = "https://codecastle.store/api/explore"
    
    private init() {}
    
    // MARK: - Get All Posts
    func fetchPosts(page: Int = 1, limit: Int = 20, active: Bool = true) async throws -> (posts: [ExplorePost], pagination: Pagination?) {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "active", value: "\(active)")
        ]
        
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        
        // Create request with cache control to prevent caching
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let responseData = try JSONDecoder().decode(ExplorePostsResponse.self, from: data)
        return (responseData.data.posts, responseData.data.pagination)
    }
    
    // MARK: - Get Single Post
    func fetchPost(id: String) async throws -> ExplorePost {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            throw URLError(.badURL)
        }
        
        // Create request with cache control to prevent caching
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.httpMethod = "GET"
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let responseData = try JSONDecoder().decode(ExplorePostResponse.self, from: data)
        return responseData.data.post
    }
}

