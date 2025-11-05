//
//  IntroView.swift
//  Kochi One
//
//  Created by Muhammed Younus on 05/11/25.
//


import SwiftUI

struct IntroView: View {
    
    @State private var activePage: Page = .page1
    @AppStorage("hasSeenIntro")var hasSeenIntro :Bool = false
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                let size = proxy.size

                VStack {
                    Spacer(minLength: 0)

                   
                    MorphingSymbolView(
                        symbol: activePage.rawValue,
                        config: .init(
                            font: .system(size: 150, weight: .bold),
                            frame: .init(width: 250, height: 200),
                            radius: 30,
                            foregroundColor: .white,
                            keyframeDuration: 0.4,
                            symbolAnimation: .smooth(duration: 0.5, extraBounce: 0)
                        )
                    )

                   
                    TextContents(size: size)

                    Spacer(minLength: 0)

                   
                    IndicatorView()

                    
                    ContinueButton()
                }
                .frame(maxWidth: .infinity)
                .overlay(alignment: .top) {
                    HeaderView()
                }
                .navigationDestination(isPresented: $navigateToHome) {
                    HomeView()
                        .navigationBarBackButtonHidden(true)
                }
            }
            .background {
                Rectangle()
                    .fill(.black.gradient)
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: Text Section
    @ViewBuilder
    func TextContents(size: CGSize) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(Page.allCases, id: \.rawValue) { page in
                    Text(page.title)
                        .lineLimit(1)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .kerning(1.1)
                        .frame(width: size.width)
                }
            }
            .offset(x: -activePage.index * size.width)
            .animation(.bouncy(duration: 0.7), value: activePage)

            HStack(alignment: .top, spacing: 0) {
                ForEach(Page.allCases, id: \.rawValue) { page in
                    Text(page.subTitle)
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.gray)
                        .frame(width: size.width)
                }
            }
            .offset(x: -activePage.index * size.width)
            .animation(.bouncy(duration: 0.9), value: activePage)
        }
        .padding(.top, 15)
        .frame(width: size.width, alignment: .leading)
    }

    // MARK: Indicator Dots
    @ViewBuilder
    func IndicatorView() -> some View {
        HStack(spacing: 6) {
            ForEach(Page.allCases, id: \.rawValue) { page in
                Capsule()
                    .fill(.white.opacity(activePage == page ? 1 : 0.4))
                    .frame(width: activePage == page ? 25 : 8, height: 8)
            }
        }
        .animation(.smooth(duration: 0.5), value: activePage)
        .padding(.bottom, 12)
    }

    // MARK: Header Buttons
    @ViewBuilder
    func HeaderView() -> some View {
        HStack {
            Button {
                activePage = activePage.previousPage
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .contentShape(.rect)
            }
            .opacity(activePage != .page1 ? 1 : 0)

            Spacer(minLength: 0)

            Button("Skip") {
                activePage = .page4
            }
            .fontWeight(.semibold)
            .opacity(activePage != .page4 ? 1 : 0)
        }
        .foregroundStyle(.white)
        .animation(.snappy(duration: 0.35), value: activePage)
        .padding(15)
    }

    // MARK: Continue / Kochione Button
    @ViewBuilder
    func ContinueButton() -> some View {
        Button {
            if activePage == .page4 {
                print("(1)Intro completed. Flag saved: \(hasSeenIntro)")
                hasSeenIntro = true
                print("Intro completed. Flag saved: \(hasSeenIntro)")
                navigateToHome = true
            } else {
                activePage = activePage.nextPage
            }
        } label: {
            Text(activePage == .page4 ? "Get Started " : "Continue")
                .contentTransition(.identity)
                .foregroundStyle(.black)
                .padding(.vertical, 15)
                .frame(maxWidth: activePage == .page4 ? 220 : 180)
                .background(.white, in: .capsule)
        }
        .padding(.bottom, 15)
        .animation(.smooth(duration: 0.5), value: activePage)
    }
}

struct HomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text(" Welcome to Kochione")
                .font(.title)
                .fontWeight(.bold)

            Text("This is your main app screen.")
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .transition(.move(edge: .trailing))
    }
}

#Preview {
    IntroView()
}