////
////  MenuView.swift
////  Kochi One
////
////  Created by APPLE on 06/10/2025.
////
//
//
////
////  ContentView.swift
////  StickyHeaderList
////
////  Created by Balaji Venkatesh on 10/09/25.
////
//
//import SwiftUI
//
//struct MenuView: View {
//    /// Mock Data
//    @State private var menuCards: [MenuCard] = [
//        .init(title: "Order Again"),
//        .init(title: "Picked For You"),
//        .init(title: "Starters"),
//        .init(title: "French")
//    ]
//    @State private var currentMenuTitle: String?
//    var body: some View {
//        ScrollViewReader { reader in
//            CustomList { progress in
//            } topContent: { progress, safeAreaTop in
//                HeroImage(progress, safeAreaTop)
//            } header: { progress in
//                HeaderView(progress)
//            } content: {
//                ForEach(menuCards) { card in
//                    Section {
//                        ForEach(card.items) { _ in
//                            DummyCardView()
//                                /// Gives spacing of 10!
//                                .customListRow(top: 5, bottom: 5)
//                        }
//                    } header: {
//                        Text(card.title)
//                            .font(.title2.bold())
//                            .padding(15)
//                            .onGeometryChange(for: CGFloat.self) {
//                                $0.frame(in: .global).minY
//                            } action: { newValue in
//                                updateCurrentMenuTitle(card: card, offset: newValue)
//                            }
//                            .id(card.id)
//                            .customListRow()
//                    }
//                }
//            }
//            .modifiers { content in
//                if #available(iOS 18, *) {
//                    content
//                        .onScrollPhaseChange { oldPhase, newPhase, context in
//                            let offset = context.geometry.contentOffset.y + context.geometry.contentInsets.top
//                            if newPhase == .idle && offset > 0 {
//                                guard let firstCardID = menuCards.first?.id else { return }
//                                
//                                if offset < 250 {
//                                    if offset < 125 {
//                                        /// Reset to top
//                                        withAnimation(.easeInOut(duration: 0.2)) {
//                                            reader.scrollTo(firstCardID, anchor: .bottom)
//                                        }
//                                    } else {
//                                        /// Reset to header view
//                                        withAnimation(.easeInOut(duration: 0.2)) {
//                                            reader.scrollTo(firstCardID, anchor: .top)
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                } else {
//                    content
//                }
//            }
//        }
//        .task {
//            guard currentMenuTitle == nil else { return }
//            currentMenuTitle = menuCards.first?.title
//        }
//    }
//    
//    /// Top Hero Image
//    @ViewBuilder
//    func HeroImage(_ progress: CGFloat, _ safeAreaTop: CGFloat) -> some View {
//        CarouselView()
//    }
//    
//    /// Custom Header View
//    @ViewBuilder
//    func HeaderView(_ progress: CGFloat) -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Apple Foods")
//                .font(.title2.bold())
//                .frame(height: 35)
//                .offset(x: min(progress * 1.1, 1) * 45)
//            
//            let opacity = max(0, 1 - (progress * 1.2))
//            let currentMenuTitleOpacity = max(progress - 0.9, 0) * 10
//            
//            HStack(spacing: 6) {
//                Image(systemName: "star.fill")
//                    .font(.caption)
//                
//                Text("4.5 **(20K ratings)**")
//                    .font(.callout)
//                
//                Image(systemName: "clock")
//                    .font(.system(size: 15, weight: .semibold))
//                    .padding(.leading, 10)
//                
//                Text("35-40 **Mins**")
//                    .font(.callout)
//            }
//            .opacity(opacity)
//            .overlay(alignment: .leading) {
//                Text(currentMenuTitle ?? "")
//                    .font(.system(size: 14))
//                    .foregroundStyle(.gray)
//                    .fontWeight(.medium)
//                    .contentTransition(.numericText())
//                    .animation(.snappy, value: currentMenuTitle)
//                    .offset(x: 45, y: -5)
//                    .opacity(currentMenuTitleOpacity)
//            }
//        }
//        .padding(.horizontal, 15)
//        .padding(.vertical, 10)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background {
//            /// Starts only after the progress goes beyond 0.8 and gives in a progress range between 0-1
//            let backgroundProgress = max(progress - 0.8, 0) * 5
//            
//            Rectangle()
//                .fill(.background)
//                /// Increasing the background till the safe area top!
//                .padding(.top, backgroundProgress * -100)
//                /// Shadow
//                .shadow(color: .gray.opacity(backgroundProgress * 0.3), radius: 1, x: 0, y: 1)
//        }
//    }
//    
//    /// Nav Bar View
//    @ViewBuilder
//    func NavBarView() -> some View {
//        HStack {
//            Button {
//                
//            } label: {
//                Image(systemName: "chevron.left.circle.fill")
//                    .font(.system(size: 30))
//                    .foregroundStyle(Color.primary, .background)
//                    .shadow(radius: 2)
//                    .frame(height: 35)
//            }
//            
//            Spacer()
//            
//            Button {
//                
//            } label: {
//                Image(systemName: "ellipsis.circle.fill")
//                    .font(.system(size: 30))
//                    .foregroundStyle(Color.primary, .background)
//                    .shadow(radius: 2)
//                    .frame(height: 35)
//            }
//        }
//        .padding(.horizontal, 15)
//        /// Matching the top padding with the Header's top padding!
//        .padding(.top, 10)
//    }
//    
//    func updateCurrentMenuTitle(card: MenuCard, offset: CGFloat) {
//        if offset < 200 {
//            if card.title != currentMenuTitle {
//                currentMenuTitle = card.title
//            }
//        } else {
//            /// Going back to previous selection!
//            if currentMenuTitle == card.title && card.id != menuCards.first?.id {
//                /// Finding Previous Index
//                if let currentIndex = menuCards.firstIndex(where: { $0.id == card.id }) {
//                    let previousIndex = max(menuCards.index(before: currentIndex), 0)
//                    currentMenuTitle = menuCards[previousIndex].title
//                }
//            }
//        }
//    }
//    
//    
//}
//
//extension View {
//    @ViewBuilder
//    func modifiers<Content: View>(@ViewBuilder content: @escaping (Self) -> Content) -> some View {
//        content(self)
//    }
//}
//
//#Preview {
//    MenuView()
//}
//
///// Header Image Link: https://www.pexels.com/photo/photo-of-sliced-cake-2147834/
