//
//  TrendingCarouselType.swift
//  Kochi One
//
//  Created by Muhammed Younus on 27/11/25.
//


//
//  TrendingCarouselType.swift
//  Kochi One
//
//  Created by Subin Kurian on 27/11/25.
//



import SwiftUI

enum TrendingCarouselType: String, CaseIterable {
//    case type1 = "Complete"
//    case type2 = "Opacity"
//    case type3 = "Scale"
    case type4 = "Both"
}

struct CustomCarouselTrendingView: View {
    @State private var activeID: UUID?
    @State private var TrendingCarouselType: TrendingCarouselType = .type4
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                CustomCarouselTrending(
                    config: .init(
                        hasOpacity: TrendingCarouselType == .type4,
                        hasScale: TrendingCarouselType == .type4,
                        cardWidth: 200
                    ),
                    selection: $activeID,
                    data: images
                )
                { image in
                    GeometryReader { _ in
                        Image(image.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    
                    .clipped()
                    
                }
//                .frame(height: 100)
                .animation(.snappy(duration: 0.3, extraBounce: 0), value: TrendingCarouselType)
//                .padding(.top, 5)
                
                
//                VStack(spacing: 15) {
//                    Text("Config")
//                        .font(.caption)
//                        .foregroundStyle(.gray)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    Picker("", selection: $carouselType) {
//                        ForEach(CarouselType.allCases, id: \.rawValue) {
//                            Text($0.rawValue)
//                                .tag($0)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                }
//                .padding(15)
//                .background(.gray.opacity(0.08), in: .rect(cornerRadius: 15))
              
//                
//                Spacer()
            }
//            .offset(y:-85)
//            .padding()
//            .navigationTitle("Cover Carousel")
        }
    }
}

//#Preview {
//    ContentView()
//}