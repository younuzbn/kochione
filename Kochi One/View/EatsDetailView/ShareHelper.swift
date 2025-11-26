//
//  ShareHelper.swift
//  Kochi One
//
//  Created on 26/11/25.
//

import UIKit
import SwiftUI

struct ShareHelper {
    static func shareRestaurant(_ restaurant: Restaurant) {
        // Create deep link URL with properly encoded restaurant biz_id
        let encodedBizId = restaurant.bizId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? restaurant.bizId
        let deepLinkURL = "kochione://restaurant?biz_id=\(encodedBizId)"
        let shareText = "Check out \(restaurant.name)!\n\n\(restaurant.description)\n\nLocation: \(restaurant.address.street), \(restaurant.address.city)\n\n\(deepLinkURL)"
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController,
              let url = URL(string: deepLinkURL) else {
            return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText, url],
            applicationActivities: nil
        )
        
        // For iPad support
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // Find the topmost view controller
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        topController.present(activityViewController, animated: true)
    }
}

