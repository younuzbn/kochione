//
//  Cards.swift
//  Kochi One
//
//  Created by Muhammed Younus on 25/11/25.
//


//
//  Card.swift
//  Kochi One
//
//  Created by Subin Kurian on 11/11/25.
//


//
//  card.swift
//  demo
//
//  Created by Subin Kurian on 10/11/25.
//

import SwiftUI
struct Cards: Identifiable, Hashable {
    var id: UUID = .init()
    var title: String
    var subtitle: String
    var image: String
}

var card: [Cards] = [
    .init(title: "PS5", subtitle: "Marvel’s Spider-Man 2", image: "Playstation"),
    .init(title: "PS5", subtitle: "4K gaming up to 120 FPS", image: "Playstation1"),
    .init(title: "PS5", subtitle: "DualSense wireless controller", image: "Playstation2"),
]