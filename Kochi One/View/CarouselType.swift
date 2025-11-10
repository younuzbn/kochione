////
////  CarouselType.swift
////  Kochi One
////
////  Created by APPLE on 06/10/2025.
////
//
//
////
////  CarouselType.swift
////  StickyHeaderList
////
////  Created by APPLE on 05/10/2025.
////
//
//
////
////  ContentView.swift
////  CoverCarousel
////
////  Created by Balaji Venkatesh on 24/07/24.
////
//
//import SwiftUI
//
//enum CarouselType: String, CaseIterable {
//    case type1 = "Complete"
//    case type2 = "Opacity"
//    case type3 = "Scale"
//    case type4 = "Both"
//}
//
//struct CarouselView: View {
//    @State private var activeID: UUID?
//    @State private var carouselType: CarouselType = .type3
//    var body: some View {
//            VStack(spacing: 15) {
//                CustomCarousel(
//                    config: .init(
//                        hasOpacity: carouselType == .type4 || carouselType == .type2,
//                        hasScale: carouselType == .type4 || carouselType == .type3,
//                        cardWidth: 200
//                    ),
//                    selection: $activeID,
//                    data: images
//                ) { image in
//                    GeometryReader { _ in
//                        Image(image.image)
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                    }
//                    .clipped()
//                }
//                .frame(height: 170)
//                .animation(.snappy(duration: 0.3, extraBounce: 0), value: carouselType)
//                .padding(.top, 35)
//
//                
//                Spacer()
//        }
//    }
//}
//
//#Preview {
//    CarouselView()
//}
