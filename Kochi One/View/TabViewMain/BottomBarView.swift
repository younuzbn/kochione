//
//  BottomBarView.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//

import SwiftUI

struct BottomBarView: View {
    @State private var searchText: String = ""
    @FocusState var isFocused: Bool
    @State private var activeTab: AppTab = .explore
    @State private var addItemView: Bool = false
    @Binding var currentDetent: AppTab.CustomDetent
    @Binding var showRestaurants: Bool
    @State private var activeSheet: SheetType?
    @State private var userProfileImage: UIImage?
    @State private var currentUserName: String = "User Name"
    @State private var selectedRestaurantName: String?
    @ObservedObject var locationService: LocationService
    @StateObject private var restaurantService = RestaurantService()
//    @StateObject private var searchViewModel = RestaurantSearchViewModel()
    
    // Use an enum to track which sheet to show
        enum SheetType: Identifiable {
            case qrScanner
            case profile
            
            var id: Int {
                switch self {
                case .qrScanner: return 1
                case .profile: return 2
                }
            }
        }
    var body: some View {
        GeometryReader {
            let safeArea = $0.safeAreaInsets
            let bottomPadding = safeArea.bottom / 5
            
            VStack(spacing: 0) {
                TabView(selection: $activeTab) {
                    Tab.init(value: .explore) {
                        IndividualTabView(.explore)
                    }
                    
                    Tab.init(value: .eats) {
                        IndividualTabView(.eats)
                    }
                    
                    Tab.init(value: .play) {
                        IndividualTabView(.play)
                    }
                    
                    Tab.init(value: .fitness) {
                        IndividualTabView(.fitness)
                    }
                    
                    Tab.init(value: .transit) {
                        IndividualTabView(.transit)
                    }
                }
                .tabViewStyle(.tabBarOnly)
                .background {
                    if #available(iOS 26, *) {
                        TabViewHelper()
                    }
                }
                .compositingGroup()
                
                CustomTabBar()
                    .padding(.bottom, isiOS26 ? bottomPadding : 0)
            }
            .ignoresSafeArea(.all, edges: isiOS26 ? .bottom : [])
        }
        .onAppear {
            // Fetch restaurants once when the view appears
            restaurantService.fetchRestaurants()
            // Only show restaurants in Eats tab
            showRestaurants = activeTab == .eats
            // Update metro map state
            let metroMapState = MetroMapState.shared
            metroMapState.isMetroTabActive = (activeTab == .transit)
            metroMapState.showMetroStations = (activeTab == .transit)
        }
        .onChange(of: activeTab) { _, newValue in
            // Only show restaurants in Eats tab
            showRestaurants = newValue == .eats
            // Update metro map state
            let metroMapState = MetroMapState.shared
            metroMapState.isMetroTabActive = (newValue == .transit)
            metroMapState.showMetroStations = (newValue == .transit)
        }
        .interactiveDismissDisabled()
        // Use activeSheet to manage the presentation and content
        .sheet(item: $activeSheet) { sheetType in
            switch sheetType {
            case .qrScanner:
                QRScannerView(
                    showQRScanner: Binding(
                        get: { activeSheet == .qrScanner },
                        set: { if !$0 { activeSheet = nil } }
                    ),
                    selectedTab: $activeTab
                )
                .presentationDetents([.medium])
            case .profile:
                ProfileView(profileView: Binding(
                                get: { activeSheet == .profile },
                                set: { if !$0 { activeSheet = nil } }
                        ),
                        userProfileImage: $userProfileImage,
                        userName: $currentUserName
                )
                
                
                // You can set presentationDetents for ProfileView if needed
                .presentationDetents([.large])
            }
        }
    }
    
    /// Individual Tab View
    @ViewBuilder
    func IndividualTabView(_ tab: AppTab) -> some View {
        ScrollView(.vertical) {
            VStack {
                VStack {
                    HStack {
                        TextField("Search restaurants.. ",  text: $searchText)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(.gray.opacity(0.25), in: .capsule)
                            .focused($isFocused)
                        /// Profile/Close Button for Search Field
                        Button {
                            if isFocused {
                                isFocused = false
                            } else {
                                /// Profile Button Action
                                activeSheet = .profile
                            }
                        } label: {
                            ZStack {
                                if isFocused {
                                    Group {
                                        if #available(iOS 26, *) {
                                            Image(systemName: "xmark")
                                                .frame(width: 48, height: 48)
                                                .glassEffect(in: .circle)
                                        } else {
                                            Image(systemName: "xmark")
                                                .frame(width: 48, height: 48)
                                                .background(.ultraThinMaterial, in: .circle)
                                        }
                                    }
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.primary)
                                    .transition(.blurReplace)
                                } else {
                                    if let image = userProfileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 48, height: 48)
                                            .clipShape(Circle())
                                            .transition(.blurReplace)
                                    } else {
                                        Image("profile_placeholder")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 48, height: 48)
                                            .clipShape(Circle())
                                            .transition(.blurReplace)
                                    }
                                }
                            }
                        }
                    }
                    HStack {
                        
                        
                        Text(selectedRestaurantName ?? tab.rawValue)
                            .font(isiOS26 ? .largeTitle : .title)
                            .fontWeight(.bold)
                        
                        Spacer(minLength: 0)
                        
                        Group {
                            if #available(iOS 26, *) {
                                Button {
                                    activeSheet = .qrScanner
                                } label: {
                                    Image(systemName: "qrcode")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .frame(width: 30, height: 30)
                                }
                                .buttonStyle(.glass)
                            } else {
                                Button {
                                    activeSheet = .qrScanner
                                } label: {
                                    Image(systemName: "qrcode")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                        .buttonBorderShape(.circle)
                    }
                    .padding(.top, isiOS26 ? 15 : 10)
                    .padding(.leading, isiOS26 ? 10 : 0)

                }
            }
            .padding(15)
            
            /// Your Tab Contents Here...
            Group {
            switch tab {
            case .explore:
                ExploreView()
            case .eats:
                EatsView(activeSheet: $activeSheet, locationService: locationService, restaurantService: restaurantService, selectedRestaurantName: $selectedRestaurantName)
            case .play:
                PlayView()
            case .fitness:
                FitnessView()
            case .transit:
                TransitView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Ensures the content fills the width
        .padding(.horizontal, 15)
        }
        .scrollIndicators(.hidden)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbarBackgroundVisibility(.hidden, for: .tabBar)
    }
    
    /// Custom Tab Bar
    @ViewBuilder
    func CustomTabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                VStack(spacing: 6) {
                    Image(systemName: tab.symbolImage)
                        .font(.title3)
                        .symbolVariant(.fill)
                    
                    Text(tab.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(activeTab == tab ? Color.primary : Color.gray)
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
                .onTapGesture {
                    activeTab = tab
                    if currentDetent == .small {
                                            withAnimation(.spring()) {
                                                currentDetent = .medium // or .large for the biggest size
                                            }
                                        }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, isiOS26 ? 12 : 5)
        .overlay(alignment: .top) {
            if !isiOS26 {
                Divider()
            }
        }
    }
    
    @available(iOS 26, *)
    fileprivate struct TabViewHelper: UIViewRepresentable {
        func makeCoordinator() -> Coordinator {
            Coordinator()
        }
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.backgroundColor = .clear
            
            DispatchQueue.main.async {
                guard let compostingGroup = view.superview?.superview else { return }
                guard let swiftUIWrapperUITabView = compostingGroup.subviews.last else { return }
                
                if let tabBarController = swiftUIWrapperUITabView.subviews.first?.next as? UITabBarController {
                    /// Clearing Backgrounds
                    tabBarController.view.backgroundColor = .clear
                    tabBarController.viewControllers?.forEach {
                        $0.view.backgroundColor = .clear
                    }
                    
                    tabBarController.delegate = context.coordinator
                    
                    /// Temporary Solution!
                    tabBarController.tabBar.removeFromSuperview()
                }
            }
            
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {  }
        
        class Coordinator: NSObject, UITabBarControllerDelegate, UIViewControllerAnimatedTransitioning {
            func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
                return self
            }
            
            func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
                return .zero
            }
            
            func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
                guard let destinationView = transitionContext.view(forKey: .to) else { return }
                let containerView = transitionContext.containerView
                
                containerView.addSubview(destinationView)
                transitionContext.completeTransition(true)
            }
        }
    }

}


