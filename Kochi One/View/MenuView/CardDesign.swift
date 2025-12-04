//
//  CardDesign.swift
//  Kochi One
//
//  Created by Adarsh on 04/12/25.
//


import SwiftUI

struct CardDesign: View {
    let url = "https://images.pexels.com/photos/376464/pexels-photo-376464.jpeg?cs=srgb&dl=pexels-ash-craig-122861-376464.jpg&fm=jpg"
//    let name = "Ash Craig"
    var item: FoodItem

    var body: some View {
        HStack(spacing: 16) {
            Image(item.image)
                .resizable()
                                     .scaledToFit()
                                     .frame(width: 100, height: 115)
                                     .clipShape(RoundedRectangle(cornerRadius: 12))
            // Image Section
//            AsyncImage(url: URL(string: url)) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                        .frame(width: 100, height: 120)
//                        .background(Color.gray.opacity(0.2))
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                case .success(let image):
//                    image
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 100, height: 115)
//                        .clipShape(RoundedRectangle(cornerRadius: 12))
//
//                case .failure:
//                    Image(systemName: "photo.fill")
//                        .font(.largeTitle)
//                        .foregroundColor(.gray)
//                        .frame(width: 100, height: 120)
//
//                @unknown default:
//                    EmptyView()
//                }
//            }

            // Text / Info Section
            VStack(alignment: .leading, spacing: 6) {
                
                Text(item.name)
                    .font(.headline)

                
                HStack(spacing: 6) {

                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.white)
                            .font(.caption2)
                    }
                    .padding(6)
                    .background(Color.green)
                    .clipShape(Circle())

                    Text("4.5")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 4, height: 4)

                 
                    Text("10 – 15 min")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                }
               

                Text(item.category)
//                Text("Bakery, Dessert")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }


            Spacer()
        }
        .padding(.vertical,1)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        .padding(.horizontal)
    }
}

//#Preview {
//    CardDesign()
//}
