//
//  PlayView.swift
//  Kochi One
//
//  Created by Muhammed Younus on 27/10/25.
//

import SwiftUI

struct PlayView: View {
    @State private var cornerRadius: CGFloat = 15
    var body: some View {
       VStack {
            HStack{
                VStack {
                    VStack{
                        HStack {
                            VStack(alignment:.leading) {
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
                        HStack{
                            Spacer()
                            Image("game3")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .padding()
                }
                
                .frame(width: 180, height: 300)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    )
                .cornerRadius(cornerRadius)
                
                
                VStack{
                    VStack{
                        VStack{
                            HStack {
                                VStack(alignment:.leading) {
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
//                            HStack{
//                                Spacer()
//                                Image("game2")
//                                    .resizable()
//                                    .scaledToFit()
//                            }
                        }
                        .padding()
                    }
                    .frame(width: 175, height: 145)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        )
                    .cornerRadius(cornerRadius)
                    VStack{
                        VStack{
                            HStack {
                                VStack(alignment:.leading) {
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
//                            HStack{
//                                Spacer()
//                                Image("game1")
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 50, height: 50)
//
//                            }

                        }
                        .padding()
                    }
                    
                    .frame(width: 175, height: 145)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        )
                    .cornerRadius(cornerRadius)
                }
            }
//                            VStack{
                HStack{
                    VStack(alignment:.leading){
                        Text("playstation centre ")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Where Play Begins")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Spacer()
                            .frame(height: 80)
                            
                    }
                    VStack{
                        Spacer()
                        Image("game4")
                            .resizable()
                            .scaledToFit()
                    }
                }
//
//                            }
            
            .frame(maxWidth: .infinity)
            .frame( height: 150)
            
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.blue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                )
            .cornerRadius(cornerRadius)
        }
       .padding()
    }
}

#Preview {
    PlayView()
}
