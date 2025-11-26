//
//  PlayView2.swift
//  Kochi One (Updated)
//
//  Created by Muhammed Younus on 07/11/25.
//

import SwiftUI

struct PlayView: View {

    @State private var cornerRadius: CGFloat = 15 // Use the corner radius from PlayView
    @State private var showPlayStation = false

    
    var body: some View {
        // Box 1 (The Big Box) - Full Screen Container
        VStack(spacing: 16) { // Added some spacing between the main vertical boxes
            
            // --- BOX 2 (Top 50% height) - Contains Soccer (Box 4) and Cricket/Badminton (Box 5) ---
            HStack(spacing: 16) { // Added some spacing between the horizontal boxes
                
                // Box 4 (Top-left button - 50% width)
                // Contains the Soccer Content
                Button(action: {  }) {
                    VStack { // Original Soccer VStack (Now Box 4)
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Soccer")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(.white)
                                    Text("Every Kick Counts")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.white)
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.green)
                                        .frame(width: 40, height: 40)
                                        .background(Color.white)
                                        .cornerRadius(50)
                                }
                                Spacer()
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                // Placeholder for "game3" image - use a system icon or remove if asset is unavailable
                                Image("game3")
                                    .resizable()
                                    .scaledToFit()
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Make the button content fill the box
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(cornerRadius)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Button fills Box 4 space
                
                // Box 5 (Top-right vertical stack - 50% width)
                VStack(spacing: 16) { // Added spacing for the vertical split
                    
                    // Box 6 (Top vertical button inside Box 5 - 50% height)
                    // Contains the Cricket Content
                    Button(action: { print("Tapped Cricket (Box 6)") }) {
                        VStack { // Original Cricket VStack (Now Box 6)
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Cricket")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text("Your Daily Innings")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(Color.red.opacity(0.8))
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
                                gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(cornerRadius)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Button fills Box 6 space
                    
                    // Box 7 (Bottom vertical button inside Box 5 - 50% height)
                    // Contains the Badminton Content
                    Button(action: { print("Tapped Badminton (Box 7)") }) {
                        VStack { // Original Badminton VStack (Now Box 7)
                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Badminton")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text("Smash Your Day")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(.white)
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(Color.blue.opacity(0.8))
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
                                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(cornerRadius)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Button fills Box 7 space
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Box 5 container
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Box 2 container
            
            // --- BOX 3 (Bottom 50% height) - Contains Playstation Centre ---
            Button(action: { showPlayStation = true }) {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Playstation Centre")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                            Text("Where Play Begins")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white.opacity(0.9))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(Color.black)
                                    .frame(width: 44, height: 44)
                                    .background(Color.white)
                                    .cornerRadius(50)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                
                                // Optional: Add a badge or additional visual element
                                HStack(spacing: 4) {
                                    Image(systemName: "gamecontroller.fill")
                                        .font(.system(size: 12))
                                    Text("Gaming Hub")
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
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundStyle(.white)
                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.red,
                                Color.black
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        
                        // Add some visual depth with overlay
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
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Button fills Box 3 space
            
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
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Same height as Playstation button
            
        }
        .fullScreenCover(isPresented: $showPlayStation) {
            GameStation(onBack: {
                showPlayStation = false   // close the fullscreen view
            })
        }

        .padding() // Add padding around the entire grid to match your PlayView
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all, edges: .all) // Ensure it fills the screen
    }

}

//#Preview {
//    PlayView()
//}
