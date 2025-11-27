//
//  Home.swift
//  Kochi One
//
//  Created by Muhammed Younus on 27/11/25.
//


//
//  Home.swift
//  Kochi One
//
//  Created by Subin Kurian on 26/11/25.
//


import SwiftUI

struct MenuHome: View {
    @State var currentTab: TabModel = tabs.first!
    @State var currentIndex: Int = 0
    @Namespace var animation

    @State var selectedItem: FoodItem?
    @State var showDetail: Bool = false
    @State private var searchText = ""
    @FocusState private var isFocused: Bool
    @State private var selectedCategory = "Fast Food"
//    @Binding var selectedCategory: String
    @State private var isHovered = false

    // Add this computed property:
    var allFoodItems: [FoodItem] {
        tabs.flatMap { $0.items }
    }

    var body: some View {
        VStack {
            MenuHeaderView(
                searchText: $searchText,
                isFocused: _isFocused,
                isHovered: $isHovered,
                showDetail: showDetail
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(attributedTitle).font(.title.bold())
                Text(attributedSubTitle).font(.title.bold())
                Text(attributedSubTitle1).font(.title.bold())
            }
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .opacity(showDetail ? 0 : 1)
            
            GeometryReader { proxy in
                let size = proxy.size
               
                MenuCarouselView(
                    size: size,
                    currentTab: $currentTab,
                    currentIndex: $currentIndex,
                    selectedItem: $selectedItem,
                    showDetail: $showDetail,
                    allItems: allFoodItems,
                    selectedCategory: $selectedCategory,
                    animation: animation
                )
                
                    
            }
            .zIndex(-10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay {
            if let selectedItem, showDetail {
                MenuDetailView(
                    animation: animation,
                    item: selectedItem,
                    show: $showDetail
                )
            }
        }
        .background {
            Color(.clear).ignoresSafeArea()
                .onChange(of: selectedCategory) { newValue in
                    let check =  currentTab.items.filter {
                        $0.category.lowercased() == selectedCategory.lowercased()
                            }
                        
                }
                .onAppear {
//                print(  """
//                        currentTab: \(currentTab)
//                           currentIndex: \(currentIndex),
//                           selectedItem: \(selectedItem),
//                           showDetail: \(showDetail),
//                           animation: \(animation)
//                """)
            }
        }
    }

//    var attributedTitle: AttributedString {
//        var attString = AttributedString("Order now")
//
//        if let orderRange = attString.range(of: "Order") {
//            attString[orderRange].foregroundColor = .orange
//        }
//
//        if let nowRange = attString.range(of: "now") {
//            attString[nowRange].foregroundColor = .white
//        }
//
//        return attString
//    }
//
//    
//    var attributedSubTitle: AttributedString {
//        var attString = AttributedString("And savor")
//
//        if let orderRange = attString.range(of: "savor") {
//            attString[orderRange].foregroundColor = .orange
//        }
//
//        if let nowRange = attString.range(of: "And") {
//            attString[nowRange].foregroundColor = .white
//        }
//
//        return attString
//    }
//
//    var attributedSubTitle1: AttributedString {
//        var attString = AttributedString("Your favorites")
//
//        if let orderRange = attString.range(of: "Your") {
//            attString[orderRange].foregroundColor = .orange
//        }
//
//        if let nowRange = attString.range(of: "favorites") {
//            attString[nowRange].foregroundColor = .white
//        }
//
//        return attString
//    }
    var attributedTitle: AttributedString {
        var attString = AttributedString(stringLiteral: "Order now")
        attString[attString.range(of: "now")!].foregroundColor = .orange
        return attString
    }

    var attributedSubTitle: AttributedString {
        var attString = AttributedString(stringLiteral: "And savor")
        attString[attString.range(of: "And")!].foregroundColor = .orange
        return attString
    }

    var attributedSubTitle1: AttributedString {
        var attString = AttributedString(stringLiteral: "Your favorites")
        attString[attString.range(of: "favorites")!].foregroundColor = .orange
        return attString
    }


}
 

#Preview {
    MenuHome()
}
