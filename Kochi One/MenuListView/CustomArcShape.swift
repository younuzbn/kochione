//
//  CustomArcShape.swift
//  Kochi One
//
//  Created by Subin Kurian on 26/11/25.
//


import SwiftUI

struct CustomArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in

            // top-left
            path.move(to: .zero)

            // left edge down full height
            path.addLine(to: CGPoint(x: 0, y: rect.height))

            // bottom curve
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: rect.height),
                control: CGPoint(x: rect.width / 2, y: rect.height + 80)
            )

            // right edge back to top
            path.addLine(to: CGPoint(x: rect.width, y: 0))

            // close shape
            path.closeSubpath()
        }
    }
}
