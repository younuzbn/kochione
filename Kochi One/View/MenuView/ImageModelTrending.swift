//
//  ImageModelTrending.swift
//  Kochi One
//
//  Created by Muhammed Younus on 27/11/25.
//


//
//  ImageModel.swift
//  Kochi One
//
//  Created by Subin Kurian on 27/11/25.
//

import SwiftUI

struct ImageModelTrending: Identifiable {
    var id: UUID = .init()
    var image: String
}

var image: [ImageModelTrending] = (1...9).compactMap({ ImageModelTrending(image: "Profile \($0)") })