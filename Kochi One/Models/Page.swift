//
//  Page.swift
//  Kochi One
//
//  Created by Muhammed Younus on 05/11/25.
//


//
//  Pages.swift
//  kochione
//
//  Created by subin kurian on 21/10/25.
//

import SwiftUI


enum Page: String, CaseIterable{
    
    case page1 = "fork.knife"
    case page2 = "takeoutbag.and.cup.and.straw.fill"
    case page3 = "bus.doubledecker.fill"
    case page4 = "car.rear.fill"
    
    var title : String{
        switch self{
        case .page1: "Food"
        case .page2: "Mind"
        case .page3: "Adventure"
        case .page4: "Ride"
        }
    }
    
    var subTitle: String{
        switch self{
        case .page1: "Eat well, travel often."
        case .page2: "Your body can, your mind must believe."
        case .page3: "Adventure is calling, and I must go."
        case .page4: "Enjoy the ride, not just the destination."
        }
    }
    
    var index:CGFloat{
        switch self {
        case.page1:0
            
        case.page2:1
            
        case.page3:2
            
        case.page4:3
            
        }
    }
    
    var nextPage:Page {
        let index = Int (self.index) + 1
        if index < 4  {
            return Page.allCases[index]
        }
        return self
    }
    
    
    var previousPage:Page {
        let index = Int (self.index) - 1
        if index >= 0  {
            return Page.allCases[index]
        }
        return self
    }
    
    
}


