//
//  ImageModel.swift
//  Kochi One
//
//  Created by APPLE on 06/10/2025.
//


//
//  ImageModel.swift
//  StickyHeaderList
//
//  Created by APPLE on 05/10/2025.
//


//
//  Image.swift
//  CoverCarousel
//
//  Created by Balaji Venkatesh on 24/07/24.
//

import SwiftUI

struct ImageModel: Identifiable {
    var id: UUID = .init()
    var image: String
}

var images: [ImageModel] = (1...8).compactMap({ ImageModel(image: "Profile \($0)") })
