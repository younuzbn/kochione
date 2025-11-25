//
//  DeepLinkDetailView.swift
//  Kochi One
//
//  Created on 01/10/2025.
//

import SwiftUI
internal import Combine

struct DeepLinkDetailView: View {
    let bizId: String
    @StateObject private var restaurantService = RestaurantService()
    @StateObject private var locationService = LocationService()
    @State private var restaurant: Restaurant?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var cancellables = Set<AnyCancellable>()
    @Binding var showContentView: Bool
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading restaurant...")
                        .padding(.top)
                        .foregroundColor(.secondary)
                }
            } else if let restaurant = restaurant {
                EatsDetailView(restaurant: restaurant, locationService: locationService) {
                    // Back button action - navigate to ContentView
                    showContentView = true
                }
            } else if let errorMessage = errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Error loading restaurant")
                        .font(.headline)
                    
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Go Back") {
                        showContentView = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showContentView = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .onAppear {
            fetchRestaurant()
        }
    }
    
    private func fetchRestaurant() {
        isLoading = true
        errorMessage = nil
        
        restaurantService.fetchRestaurant(by: bizId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [self] completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ Restaurant fetch error: \(error)")
                        errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [self] fetchedRestaurant in
                    print("✅ Successfully fetched restaurant: \(fetchedRestaurant.name)")
                    restaurant = fetchedRestaurant
                }
            )
            .store(in: &cancellables)
    }
}

