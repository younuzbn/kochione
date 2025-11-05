//
//  MorphingSymbolView.swift
//  Kochi One
//
//  Created by Muhammed Younus on 05/11/25.
//


//
//  MorphingSymbol.swift
//  kochione
//
//  Created by subin kurian on 21/10/25.
//

import SwiftUI

struct MorphingSymbolView: View {
    var symbol: String
    var config: Config
    @State private var trigger : Bool = false
    @State private var displayingsymbol : String = ""
    @State private var nextsymbol : String = ""
    var body: some View {
        Canvas { ctx, size in
            ctx.addFilter(.alphaThreshold(min: 0.4, color: config.foregroundColor))
            if let renderedImage = ctx.resolveSymbol(id: 0){
                ctx.draw(renderedImage, at: CGPoint(x: size.width / 2, y: size.height/2))
            }
            
        } symbols: {
            ImageView()
                .tag(0)
        }
        .frame(width: config.frame.width, height: config.frame.height)
        .onChange(of: symbol){oldValue, newValue in
            trigger.toggle()
            nextsymbol = newValue
            
            
        }
        .task {
            guard displayingsymbol == "" else {return}
            displayingsymbol = symbol
                
            
        }

        
    }
    
    @ViewBuilder
    func ImageView () -> some View {
        KeyframeAnimator(initialValue: CGFloat.zero, trigger:trigger){radius in
            Image(systemName: displayingsymbol == "" ? symbol : displayingsymbol)
                .font(config.font)
                .blur(radius:radius)
                .frame(width: config.frame.width, height: config.frame.height)
                .onChange(of: radius){ oldValue, newValue in
                    if newValue .rounded() == config.radius{
                        withAnimation(config.symbolAnimation){
                            displayingsymbol = nextsymbol
                        }
                        
                    }
                    
                }
               
            
            
            
        } keyframes:{ _ in
            
            CubicKeyframe(config.radius, duration: config.keyframeDuration)
            CubicKeyframe(0, duration: config.keyframeDuration)
         
        }
        
    }
    
    struct Config {
        var font :Font
        var frame :CGSize
        var radius :CGFloat
        var foregroundColor : Color
        var keyframeDuration: CGFloat = 0.4
        var symbolAnimation:Animation = .smooth(duration:0.5,extraBounce:0)
    }
}

#Preview {
    MorphingSymbolView(symbol: "gearshape.fill", config: .init(font: .system(size:100,weight: .bold), frame: CGSize(width: 250, height:200), radius: 15, foregroundColor: .black))
}
