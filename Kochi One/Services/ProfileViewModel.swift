//
//  ProfileViewModel.swift
//  Kochi One
//
//  Created on 27/11/25.
//

import Foundation
import SwiftUI
import UIKit
internal import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedImage: UIImage?
    @Published var profileImage: UIImage?
    
    private let deviceId: String
    private let apiService = PublicUserProfileService.shared
    
    init(deviceId: String) {
        self.deviceId = deviceId
    }
    
    // MARK: - Load Profile
    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await apiService.getProfile(deviceId: deviceId)
            
            // Load profile image if exists
            if let imageUrl = profile?.profileImage?.url {
                profileImage = await apiService.loadImage(from: imageUrl)
            }
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - Create Profile
    func createProfile(fullName: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await apiService.createProfile(
                deviceId: deviceId,
                fullName: fullName,
                profileImage: selectedImage
            )
            
            // Load profile image if exists
            if let imageUrl = profile?.profileImage?.url {
                profileImage = await apiService.loadImage(from: imageUrl)
            }
            
            selectedImage = nil
            isLoading = false
            return true
        } catch {
            errorMessage = handleError(error)
            isLoading = false
            return false
        }
    }
    
    // MARK: - Update Profile
    func updateProfile(fullName: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await apiService.updateProfile(
                deviceId: deviceId,
                fullName: fullName,
                profileImage: selectedImage
            )
            
            // Load updated profile image if exists
            if let imageUrl = profile?.profileImage?.url {
                profileImage = await apiService.loadImage(from: imageUrl)
            }
            
            selectedImage = nil
            isLoading = false
            return true
        } catch {
            errorMessage = handleError(error)
            isLoading = false
            return false
        }
    }
    
    // MARK: - Delete Profile Image
    func deleteProfileImage() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            profile = try await apiService.deleteProfileImage(deviceId: deviceId)
            profileImage = nil
            isLoading = false
            return true
        } catch {
            errorMessage = handleError(error)
            isLoading = false
            return false
        }
    }
    
    // MARK: - Delete Profile
    func deleteProfile() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteProfile(deviceId: deviceId)
            profile = nil
            profileImage = nil
            isLoading = false
            return true
        } catch {
            errorMessage = handleError(error)
            isLoading = false
            return false
        }
    }
    
    // MARK: - Error Handling
    private func handleError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.message
        } else if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "No internet connection"
            case .timedOut:
                return "Request timed out"
            default:
                return "Network error occurred"
            }
        } else {
            return error.localizedDescription
        }
    }
}

