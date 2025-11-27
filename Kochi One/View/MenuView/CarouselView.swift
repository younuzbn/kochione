//
//  CarouselView.swift
//  Kochi One
//
//  Created by Muhammed Younus on 27/11/25.
//


//
//  CarouselView.swift
//  Kochi One
//
//  Created by Subin Kurian on 26/11/25.
//


import SwiftUI
struct MenuCarouselView: View {
    
    let size: CGSize
    
    @Binding var currentTab: TabModel
    @Binding var currentIndex: Int
    @Binding var selectedItem: FoodItem?
    @Binding var showDetail: Bool
    @State private var selectedTab: Int = 0
    let allItems: [FoodItem] 
    @Binding var selectedCategory: String
    @State private var options = [
        
        "Fast Food",
        "Soft Drinks",
        "Starters",
        "Desserts",
        "Main Course",
        
       
    ]
    var animation: Namespace.ID
    
//
    var filteredItems: [FoodItem] {
           allItems.filter { $0.category.lowercased() == selectedCategory.lowercased() }
       }
    
    var body: some View {
        VStack(spacing: 16) {// and the spacing -40 changed in 16
            CustomCarouselTrendingView()
                .padding(.top,100)
                .padding(.bottom,-90)
                .frame(height: 200)
            MenuCustomCarousels(
//
                index: $currentIndex,
                             items: filteredItems,
                             spacing: 0,
                             id: \.id
            ) { item, _ in
                
                VStack(spacing: 10) {
                    
                    // MARK: SMOOTH ANIMATION CONTAINER
                    ZStack {
                        if showDetail && selectedItem?.id == item.id {
                            
                            ZStack {
                                Image(item.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                            .frame(width: 250, height: 250)
                            .opacity(0)
                            
                        } else {
                            
                         
                            ZStack {
                                Image(item.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .matchedGeometryEffect(id: item.id, in: animation)
                            }
                            .frame(width: 250, height: 250)
                        }
                    }
                    
                    Text(item.name)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                    
                    Text("₹\(item.price)")
                        .font(.callout)
                        .fontWeight(.black)
                        .foregroundColor(Color("blue"))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.5,
                    dampingFraction: 0.8, blendDuration: 0.8)) {
                        selectedItem = item
                        showDetail = true
                    }
                }
            }.offset(y:80)
            .frame(height: size.height * 0.75)// this height 0.8 changed in 0.75
            
            MenuIndicators(
//                count: currentTab.items.count,
//                currentIndex: $currentIndex,
//                animation: animation
                count: filteredItems.count,
                currentIndex: $currentIndex,
                animation: animation
            )
        }
        .padding(.bottom, 10)
        .frame(width: size.width, height: size.height, alignment: .bottom)
        .opacity(showDetail ? 0 : 1)
        .background {
            
            MenuCustomArcShape()
                .fill(.white)
                .scaleEffect(showDetail ? 1.8 : 1, anchor: .bottomLeading)
                .overlay(alignment: .topLeading) {
//
                    
                    MenuCustomControl(
                           selection: $selectedCategory,
                           options:options
                       )
                    .offset(y:showDetail ? -1000 : 165)
                }
                .padding(.top, 40)
                .ignoresSafeArea()
        }
//        .onChange(of: selectedCategory) { newValue in
//            let check =  currentTab.items.filter {
//                $0.category.lowercased() == selectedCategory.lowercased()
//                        }
//            print(check)
            
//            print("Items count:", tabs[selectedTab].items.count)

            
        }
    }
//}

#Preview{
    MenuHome()
}
