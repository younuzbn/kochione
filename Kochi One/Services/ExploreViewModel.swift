//
//  ExploreViewModel.swift
//  Kochi One
//
//  Created on 27/11/25.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class ExploreViewModel: ObservableObject {
    @Published var posts: [ExplorePost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = ExploreService.shared
    
    // MARK: - Fetch Posts
    func fetchPosts(page: Int = 1, limit: Int = 20, active: Bool = true) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let (fetchedPosts, _) = try await apiService.fetchPosts(page: page, limit: limit, active: active)
            // Filter by isActive and sort by listPosition
            self.posts = fetchedPosts
                .filter { $0.isActive } // Additional client-side filter for safety
                .sorted { $0.listPosition < $1.listPosition }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error fetching explore posts: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Fetch Single Post
    func fetchPost(id: String) async -> ExplorePost? {
        do {
            return try await apiService.fetchPost(id: id)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error fetching explore post: \(error)")
            return nil
        }
    }
}

