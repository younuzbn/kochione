//
//  CustomList.swift
//  Kochi One
//
//  Created by APPLE on 01/10/2025.
//


//
//  CustomList.swift
//  StickyHeaderList
//
//  Created by Balaji Venkatesh on 10/09/25.
//

import SwiftUI

struct CustomList<NavBar: View, TopContent: View, Header: View, Content: View>: View {
    @ViewBuilder var navBar: (_ progress: CGFloat) -> NavBar
    @ViewBuilder var topContent: (_ progress: CGFloat, _ safeAreaTop: CGFloat) -> TopContent
    @ViewBuilder var header: (_ progress: CGFloat) -> Header
    @ViewBuilder var content: Content
    /// View Properties
    @State private var headerProgress: CGFloat = 0
    @State private var safeAreaTop: CGFloat = 0
    @State private var topContentHeight: CGFloat = 0
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        List {
            topContent(headerProgress, safeAreaTop)
                .onGeometryChange(for: CGFloat.self, of: {
                    $0.size.height
                }, action: { newValue in
                    topContentHeight = newValue
                })
                .customListRow()
            
            Section {
                content
            } header: {
                header(headerProgress)
                    .foregroundStyle(foregroundColor)
                    .onGeometryChange(for: CGFloat.self, of: {
                        topContentHeight == .zero ? 0 : $0.frame(in: .named("LISTVIEW")).minY
                    }, action: { newValue in
                        guard topContentHeight != .zero else { return }
                        let progress = (newValue - safeAreaTop) / topContentHeight
                        let cappedProgress = 1 - max(min(progress, 1), 0)
                        self.headerProgress = cappedProgress
                    })
                    .customListRow()
            }
        }
        .listStyle(.plain)
        .listRowSpacing(0)
        .listSectionSpacing(0)
        .overlay(alignment: .top) {
            navBar(headerProgress)
        }
        .coordinateSpace(.named("LISTVIEW"))
        .onGeometryChange(for: CGFloat.self) {
            $0.safeAreaInsets.top
        } action: { newValue in
            safeAreaTop = newValue
        }
    }
    
    var foregroundColor: Color {
        colorScheme == .dark ? .white : .black
    }
}

extension View {
    @ViewBuilder
    func customListRow(top: CGFloat = 0, bottom: CGFloat = 0) -> some View {
        self
            .listRowInsets(.init(top: top, leading: 0, bottom: bottom, trailing: 0))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

#Preview {
    ContentView()
}
