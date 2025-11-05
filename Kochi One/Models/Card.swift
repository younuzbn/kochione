//
//  Card.swift
//  Kochi One
//
//  Created by Muhammed Younus on 05/11/25.
//


//
//  Card.swift
//  kochione
//
//  Created by subin kurian on 29/10/25.
//

import Foundation
struct Card: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var imageURL : URL
}

let cards: [Card] = [
    .init(imageURL: URL(string: "https://raw.githubusercontent.com/younuzbn/intro/main/1.webp")!),
    .init(imageURL: URL(string: "https://raw.githubusercontent.com/younuzbn/intro/main/2.webp")!),
    .init(imageURL: URL(string: "https://raw.githubusercontent.com/younuzbn/intro/main/3.webp")!),
    .init(imageURL: URL(string: "https://raw.githubusercontent.com/younuzbn/intro/main/4.webp")!),
]

