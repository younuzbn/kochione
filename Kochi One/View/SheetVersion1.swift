//
//  IntroPage.swift
//  kochione
//
//  Created by subin kurian on 29/10/25.
//
import StoreKit
import SwiftUI
internal import Combine
struct SheetVersion: View {
    /// View Properties
    @State private var activeCard: Card? = cards.first
    @State private var scrollView: UIScrollView?
    @State private var timer = Timer.publish(every: 0.01, on: .current, in: .default).autoconnect()
    @State private var initialAnimation: Bool = false
    @State private var titleProgress: CGFloat = 0
    
    let minVersion: String
    let latestVersion: String
    let currentVersion: String
    let isForceUpdate: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var showAppStore = false
    
    private func presentAppStore() {
        showAppStore = true
    }
    var body: some View {
        ZStack {
            /// Ambient Background View
            AmbientBackground()
                .animation(.easeInOut(duration: 1), value: activeCard)
            
            VStack(spacing: 40) {
                InfiniteScrollView(collection: cards) { card in
                    CarouselCardView(card)
                } uiScrollView: {
                    scrollView = $0
                } onScroll: {
                    updateActiveCard()
                }
                .scrollIndicators(.hidden)
                .scrollClipDisabled()
                .containerRelativeFrame(.vertical) { value, _ in
                    value * 0.45
                }
                .visualEffect { [initialAnimation] content, proxy in
                    content
                        .offset(y: !initialAnimation ? -(proxy.size.height + 200) : 0)
                }

                VStack(spacing: 4) {
                    Text("Whats's New in")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.secondary)
                        .blurOpacityEffect(initialAnimation)
                    
                    Group {
                        if #available(iOS 18, *) {
                            Text("Kochione")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                                .textRenderer(TitleTextRenderer(progress: titleProgress))
                        } else {
                            Text("Kochione")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    Text("KochiOne is a smart city guide app designed to help users explore Kochi with ease. It provides real-time information on nearby gym ,cafes,metro,and essential services.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.secondary)
                        .blurOpacityEffect(initialAnimation)
                }
                
                if isForceUpdate {
                    Button {
                        presentAppStore()
                    } label: {
                        Text("Update Now")
                            .fontWeight(.semibold)
                                                    .foregroundStyle(.black)
                                                    .padding(.horizontal, 25)
                                                    .padding(.vertical, 12)
                                                    .background(.white, in: .capsule)
                    }
                    .blurOpacityEffect(initialAnimation)
                } else {
                    Button {
                        presentAppStore()
                    } label: {
                        Text("Update Now")
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 12)
                            .background(.white, in: .capsule)
                    }
                    Button {
                        dismiss()
                    } label: {
                        Text("Remind Me Later!")
                    }
                }//                .blurOpacityEffect(initialAnimation)
            }
            
            .safeAreaPadding(15)
        }
        .sheet(isPresented: $showAppStore) {
            AppStoreProductView()
        }
        .onReceive(timer) { _ in
            if let scrollView = scrollView {
                scrollView.contentOffset.x += 0.35
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.35))
            
            withAnimation(.smooth(duration: 0.75, extraBounce: 0)) {
                initialAnimation = true
            }
            
            withAnimation(.smooth(duration: 2.5, extraBounce: 0).delay(0.3)) {
                titleProgress = 1
            }
        }
    }
    
    func updateActiveCard() {
        if let currentScrollOffset = scrollView?.contentOffset.x {
            let activeIndex = Int((currentScrollOffset / 220).rounded()) % cards.count
            guard activeCard?.id != cards[activeIndex].id else { return }
            activeCard = cards[activeIndex]
        }
    }
    
    @ViewBuilder
        private func AmbientBackground() -> some View {
            GeometryReader { proxy in
                let size = proxy.size
                
                ZStack {
                    ForEach(cards) { card in
                        AsyncImage(url: card.imageURL) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.3)
                                    .frame(width: size.width, height: size.height)
                                    .ignoresSafeArea()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: size.width, height: size.height)
                                    .opacity(activeCard?.id == card.id ? 1 : 0)
                                    .ignoresSafeArea()
                            case .failure:
                                Color.gray.opacity(0.3)
                                    .frame(width: size.width, height: size.height)
                                    .ignoresSafeArea()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    Rectangle()
                        .fill(.black.opacity(0.45))
                        .ignoresSafeArea()
                }
                .compositingGroup()
                .blur(radius: 90, opaque: true)
                .ignoresSafeArea()
            }
        }
    
    /// Carousel Card View
    @ViewBuilder
        private func CarouselCardView(_ card: Card) -> some View {
            GeometryReader {
                let size = $0.size
                
                AsyncImage(url: card.imageURL) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                            .frame(width: size.width, height: size.height)
                            .clipShape(.rect(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 1, y: 0)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .clipShape(.rect(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 1, y: 0)
                    case .failure:
                        Color.gray.opacity(0.3)
                            .frame(width: size.width, height: size.height)
                            .clipShape(.rect(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.4), radius: 10, x: 1, y: 0)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .frame(width: 220)
            .scrollTransition(.interactive.threshold(.centered), axis: .horizontal) { content, phase in
                content
                    .offset(y: phase == .identity ? -10 : 0)
                    .rotationEffect(.degrees(phase.value * 5), anchor: .bottom)
            }
        }
}

//#Preview {
//    SheetVersion()
//}

extension View {
    func blurOpacityEffect(_ show: Bool) -> some View {
        self
            .blur(radius: show ? 0 : 2)
            .opacity(show ? 1 : 0)
            .scaleEffect(show ? 1 : 0.9)
    }
}

struct AppStoreProductView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SKStoreProductViewController {
        let storeViewController = SKStoreProductViewController()
        storeViewController.loadProduct(withParameters: [
            SKStoreProductParameterITunesItemIdentifier: "6657981474" // Replace with your actual App Store ID
        ]) { result, error in
            if let error = error {
                print("Error loading product: \(error)")
            }
        }
        return storeViewController
    }
    
    func updateUIViewController(_ uiViewController: SKStoreProductViewController, context: Context) {
        // No updates needed
    }
}

