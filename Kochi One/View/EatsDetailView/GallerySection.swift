//
//  GallerySection.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import SwiftUI

struct GallerySection: View {
    @State private var activeID: String?
    
    let coverImages: [RestaurantImage]
    @State private var expandedImageURL: String? = nil
    @State private var imageUrl: String? = nil
    @State private var indexImage = 1
    // Calculate image width: (screen width - left padding - spacing between images) / 3
    private var imageWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let leftPadding: CGFloat = 30 // Align with other sections
        let spacing: CGFloat = 20 // 10px spacing between 3 images (2 gaps)
        return (screenWidth - leftPadding - spacing) / 3
    }
    
    // Image height should be less than width (landscape/rectangle)
    private var imageHeight: CGFloat {
        return imageWidth * 0.75 // 4:3 aspect ratio (width > height)
    }
    
    var body: some View {
        if !coverImages.dropFirst().isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                
                
                
                
                //                if let expandedURL = expandedImageURL {
                //                    // Show expanded image - height of two rows (2 × 100px + 5px spacing = 205px)
                //                    CachedAsyncImage(url: expandedURL) { image in
                //                        image
                //                            .resizable()
                //                            .aspectRatio(contentMode: .fill)
                //                    } placeholder: {
                //                        Rectangle()
                //                            .fill(.gray.opacity(0.4))
                //                            .overlay {
                //                                ProgressView()
                //                                    .tint(.blue)
                //                                    .scaleEffect(0.7)
                //                            }
                //                    }
                //                    .frame(height: 205) // 2 rows × 100px + 5px spacing
                //                    .clipShape(RoundedRectangle(cornerRadius: 10))
                //                    .onTapGesture {
                //                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                //                            expandedImageURL = nil
                //                        }
                //                    }
                //                    .transition(.scale.combined(with: .opacity))
                //                } else {
                //                    // Show all 4 images in grid
                //                    let config = ImageViewerConfig(height: 100, cornerRadius: 10, spacing: 5)
                //                    let coverImagesArray = Array(coverImages.prefix(4))
                //
                //                    ImageViewer(config: config) {
                //                        ForEach(0..<coverImagesArray.count, id: \.self) { index in
                //                            let coverImage = coverImagesArray[index]
                //                            Button {
                //                                // Directly use the index to get the correct image URL
                //                                let tappedURL = coverImagesArray[index].url
                //                                print("Tapped image at index \(index): \(tappedURL)")
                //                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                //                                    expandedImageURL = tappedURL
                //                                }
                //                            } label: {
                //                                CachedAsyncImage(url: coverImage.url) { image in
                //                                    image
                //                                        .resizable()
                //                                } placeholder: {
                //                                    Rectangle()
                //                                        .fill(.gray.opacity(0.4))
                //                                        .overlay {
                //                                            ProgressView()
                //                                                .tint(.blue)
                //                                                .scaleEffect(0.7)
                //                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                //                                        }
                //                                }
                //                            }
                //                            .buttonStyle(.plain)
                //                            .containerValue(\.activeViewID, coverImage.url)
                //                        }
                //                    }overlay: {
                //                        ProgressView()
                //                            .tint(.blue)
                //                            .scaleEffect(0.7)
                //                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                //                    }                }
                //
                
                
                
                if let expandedURL = expandedImageURL {
                    ZStack{
                        //                        index = index
                        let imageUrl = coverImages[indexImage].url
                        
                        CachedAsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(.gray.opacity(0.4))
                                .overlay {
                                    ProgressView()
                                        .tint(.blue)
                                        .scaleEffect(0.7)
                                }
                        }
                        
                        .id(imageUrl)
                        .transition(.scale.combined(with: .opacity))
                        .frame(width: 340,height: 205) // 2 rows × 100px + 5px spacing
                        .clipShape(RoundedRectangle(cornerRadius: 15))//10
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                expandedImageURL = nil
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                        HStack{
                            Button {
                                withAnimation {
                                    indexImage = (indexImage - 1 + coverImages.count) % coverImages.count
                                }
                            } label: {
                                if #available(iOS 26.0, *) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18))
                                        .bold()
                                        .foregroundStyle(.gray)
                                        .frame(width: 50,height: 50)
                                        .cornerRadius(50)
                                        .glassEffect()
                                } else {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18))
                                        .bold()
                                        .foregroundStyle(.gray)
                                        .frame(width: 50,height: 50)
                                        
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(50)
                                }
                            }
                            Spacer()
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    indexImage = (indexImage + 1) % coverImages.count
                                }
                                print("\(indexImage)url: \(coverImages[indexImage].url)")
                            } label: {
                                if #available(iOS 26.0, *) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 18))
                                        .bold()
                                        .foregroundStyle(.gray)
                                        .frame(width: 50,height: 50)
                                        .cornerRadius(50)
                                        .glassEffect()
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 18))
                                        .bold()
                                        .foregroundStyle(.gray)
                                        .frame(width: 50,height: 50)
                                        
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(50)
                                }
                            }
                        }.padding(10)
                        
                    }
                } else {
                    
                    HStack(spacing: 10) {
                        ForEach(Array(coverImages.dropFirst().enumerated()), id: \.offset) { index, media in
                            if let url = URL(string: media.url) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: imageWidth, height: imageHeight)
                                            .overlay(ProgressView())
                                        
                                    case .success(let image):
                                        Button {
                                            let url = media.url
                                            print("Tapped image \(url)")
                                            print("\(index)")
                                            
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                expandedImageURL = url
                                                //imageUrl = url
                                                indexImage = index+1
                                            }
                                            
                                        } label: {
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: imageWidth, height: imageHeight)
                                                .clipped()
                                                .cornerRadius(12)
                                        }
                                        .buttonStyle(.plain)
                                        
                                        
                                        
                                    case .failure:
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: imageWidth, height: imageHeight)
                                            .overlay(
                                                VStack(spacing: 8) {
                                                    Image(systemName: "photo")
                                                        .font(.system(size: 24))
                                                        .foregroundStyle(.gray)
                                                    Text("No Image")
                                                        .font(.system(size: 12))
                                                        .foregroundStyle(.gray)
                                                }
                                            )
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                        }
                        // Add trailing padding to match the right side
                        Spacer()
                            .frame(width: 30)
                    }
                    .onAppear{
                        print("expandedImageURL")
                    }
                    .padding(.vertical, 15)
                }
                
            }
        }
    }
}
