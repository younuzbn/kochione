//
//  Home.swift
//  Kochi One
//
//  Created by Subin Kurian on 26/11/25.
//


import SwiftUI

struct Home: View {
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
            HeaderView(
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

                CarouselView(
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
                DetailView(
                    animation: animation,
                    item: selectedItem,
                    show: $showDetail
                )
            }
        }
        .background {
            Color("blue").ignoresSafeArea()
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

    var attributedTitle: AttributedString {
        var attString = AttributedString(stringLiteral: "Order now")
        attString[attString.range(of: "now")!].foregroundColor = .white
        return attString
    }

    var attributedSubTitle: AttributedString {
        var attString = AttributedString(stringLiteral: "And savor")
        attString[attString.range(of: "And")!].foregroundColor = .white
        return attString
    }

    var attributedSubTitle1: AttributedString {
        var attString = AttributedString(stringLiteral: "Your favorites")
        attString[attString.range(of: "favorites")!].foregroundColor = .white
        return attString
    }
}
 

#Preview {
    Home()
}
