//
//  detailsPage.swift
//  Kochi One
//
//  Created by Adarsh on 11/11/25.
//


//
//  detailsPage.swift
//  Restaurants
//
//  Created by Adarsh on 10/11/25.
//

import SwiftUI

struct detailsPage: View {
    
    let screen = UIScreen.main.bounds
    var body: some View {
        ZStack(alignment: .top) {
          Image("image")
                .resizable()
                .scaledToFill()
                .frame(height: 150)
            
            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 200)
                    
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.9))
                            .frame(width: 40, height: 4)
                        Spacer().frame(height: 30)
                        VStack(alignment: .leading,spacing: 10) {
                            
                            HStack {
                                Text("Name")
                                    .font(.system(size: 18))
                                    .fontWeight(.bold)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            
                            Text("A steaming plate of butter chicken is a feast for the senses. The tender pieces of chicken are simmered in a rich, creamy tomato-based sauce, infused with aromatic spices like cumin, garam masala, and coriander. The velvety gravy carries a perfect balance of sweetness and heat, coating each piece with irresistible flavor. Served alongside warm, fluffy naan or fragrant basmati rice, the dish offers both comfort and indulgence in every bite. The golden hue of the curry and its buttery aroma make it as visually appealing as it is delicious, embodying the essence of Indian cuisine — warm, vibrant, and full of life.")
                                .lineLimit(5)
                            HStack {
                                
                                VStack {
                                    Text("Hours")
                                        .font(.system(size: 12))
                                        .bold()
                                        .foregroundStyle(Color.gray)
                                    let isOpen = true
                                    if isOpen{
                                        Text("Open")
                                            .font(.system(size: 18))
                                            .bold()
                                            .foregroundStyle(.green)
                                    }
                                    else{
                                        Text("Close")
                                            .font(.system(size: 18))
                                            .bold()
                                            .foregroundStyle(.red)
                                            .padding()
                                    }
                                    
                                }
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(Color.gray.opacity(0.9))
                                    .frame(width: 8, height:8)
                                
                                VStack {
                                    Text("Close at")
                                        .font(.system(size: 12))
                                        .bold()
                                    Text("10:00 PM")
                                        .bold()
                                }
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(Color.gray.opacity(0.9))
                                    .frame(width: 8, height:8)
                                //                                Spacer()
                                
                                VStack {
                                    Text("Rating")
                                        .font(.system(size: 18))
                                    
                                    Text("3.3")
                                        .bold()
                                }
                                .padding()
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(Color.gray.opacity(0.9))
                                    .frame(width: 8, height:8)
                                VStack {
                                    Text("Distance")
                                        .font(.system(size: 18))
                                    HStack {
                                        Image(systemName: "location.fill")
                                            .font(.system(size: 15))
                                        Text("2.6km")
                                            .bold()
                                    }
                                    
                                    
                                }
                                
                                
                                
                                
                                
                                
                            }
                            .padding(.vertical,10)
                            
                            //MARK: foreach images
                            
                            
                            //                            ScrollView(.horizontal, showsIndicators: false) {
                            //                              HStack(spacing: 10) {
                            //                                    ForEach(restaurants.first?.coverImages.dropFirst() ?? [], id: \.id){ media in
                            //                                        if let url = URL(string: media.url) {
                            //                                            AsyncImage(url: url) { phase in
                            //                                                switch phase {
                            //                                                case .empty:
                            //                                                    ProgressView()
                            //                                                        .frame(width: 200, height: 150)
                            //                                                case .success(let image):
                            //                                                    image
                            //                                                        .resizable()
                            //                                                        .scaledToFill()
                            //                                                        .frame(width: 200, height: 150)
                            //                                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                            //                                                case .failure:
                            //                                                    RoundedRectangle(cornerRadius: 15)
                            //                                                        .fill(Color.gray.opacity(0.2))
                            //                                                        .frame(width: 200, height: 150)
                            //                                                        .overlay(Text("No Image").foregroundStyle(.gray))
                            //                                                @unknown default:
                            //                                                    EmptyView()
                            //                                                }
                            //                                            }
                            //                                        }
                            //                                    }
                            //                                }
                            //                                .padding(.vertical, 5)
                            //                            }
                            
                            
                            
                            
                            
                            
                            
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height:UIScreen.main.bounds.height )
                    
                    .padding()
                    .background(
                        Color.white
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .shadow(radius: 10)
                    )
                    
                                        .offset(y: -50)
                    
                    
                }
                .zIndex(1)
                //
                .ignoresSafeArea()
                
            }
        }
    }
}
#Preview {
    detailsPage()
}

