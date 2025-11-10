//
//  FitnessView.swift
//  Kochi One
//
//  Created by Muhammed Younus on 27/10/25.
//

import SwiftUI

struct FitnessView: View {
    @State private var cornerRadius: CGFloat = 15
    
    var body: some View {
        // Box 1 (The Big Box) - Full Screen Container
        VStack(spacing: 16) {
            
            // --- BOX 2 (Top 50% height) - Contains Gym (Box 4) and Yoga/MMA (Box 5) ---
            HStack(spacing: 16) {
                
                // Box 4 (Top-left button - 50% width)
                // Contains the Gym Content
                Button(action: { print("Tapped Gym (Box 4)") }) {
                    VStack {
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Gym")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text("Build Your Strength")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(Color.orange.opacity(0.8))
                                        .frame(width: 40, height: 40)
                                        .background(Color.white)
                                        .cornerRadius(50)
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding()
                        
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.orange]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(cornerRadius)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Box 5 (Top-right vertical stack - 50% width)
                VStack(spacing: 16) {
                    
                    // Box 6 (Top vertical button inside Box 5 - 50% height)
                    // Contains the Yoga Content
                    Button(action: { print("Tapped Yoga (Box 6)") }) {
                        VStack {
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Yoga")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text("Find Your Balance")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(Color.purple.opacity(0.8))
                                            .frame(width: 40, height: 40)
                                            .background(Color.white)
                                            .cornerRadius(50)
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.purple]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(cornerRadius)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Box 7 (Bottom vertical button inside Box 5 - 50% height)
                    // Contains the MMA Content
                    Button(action: { print("Tapped MMA (Box 7)") }) {
                        VStack {
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("MMA")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text("Fight Your Way")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(Color.black.opacity(0.8))
                                            .frame(width: 40, height: 40)
                                            .background(Color.white)
                                            .cornerRadius(50)
                                    }
                                    Spacer()
                                }
                                Spacer()
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.8), Color.gray.opacity(0.9)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(cornerRadius)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // --- BOX 3 (Bottom 50% height) - Contains Fitness Centre ---
            Button(action: { print("Tapped Fitness Centre (Box 3)") }) {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fitness Centre")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Transform Your Body")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white.opacity(0.9))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.teal.opacity(0.9))
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .cornerRadius(50)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "figure.run")
                                        .font(.system(size: 12))
                                    Text("Fitness Hub")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                            }
                            .padding(.top, 8)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Image(systemName: "figure.run.treadmill")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.teal.opacity(0.7),
                                Color.cyan.opacity(0.8),
                                Color.teal
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                )
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // --- Three Snooker Image Buttons ---
            VStack(spacing: 16) {
                // Snooker Button 1
                Button(action: { print("Tapped Snooker 1") }) {
                    Image("snooker")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .cornerRadius(cornerRadius)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Snooker Button 2
                Button(action: { print("Tapped Snooker 2") }) {
                    Image("snooker2")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .cornerRadius(cornerRadius)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Snooker Button 3
                Button(action: { print("Tapped Snooker 3") }) {
                    Image("snooker3")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .cornerRadius(cornerRadius)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all, edges: .all)
    }
}

#Preview {
    FitnessView()
}
