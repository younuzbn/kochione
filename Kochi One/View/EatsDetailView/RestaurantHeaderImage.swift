//
//  RestaurantHeaderImage.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct BottomRoundedRectangle: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.width - cornerRadius, y: rect.height), control: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.height - cornerRadius), control: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

struct RestaurantHeaderImage: View {
    let imageURL: String?
    
    var body: some View {
        if let urlString = imageURL,
           let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 300)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipShape(BottomRoundedRectangle(cornerRadius: 20))
                case .failure:
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 300)
                        .overlay(Text("No Image").foregroundStyle(.gray))
                        .clipShape(BottomRoundedRectangle(cornerRadius: 20))
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 300, height: 150)
                .overlay(Text("No Image").foregroundStyle(.gray))
                .clipShape(BottomRoundedRectangle(cornerRadius: 20))
        }
    }
}

