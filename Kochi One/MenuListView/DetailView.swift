//
//  DetailView.swift
//  Kochi One
//
//  Created by Subin Kurian on 26/11/25.
//


import SwiftUI

struct DetailView: View {

    var animation: Namespace.ID
    var item: FoodItem
    @Binding var show: Bool

    @State private var showContent = false
    @State private var quantity: Int = 1
    @State private var start = false

    var body: some View {
        VStack {

            // MARK: Top Close Button
            HStack {
                Button {
                    withAnimation(.spring) {
                        start = false
                        showContent = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut) { show = false }
                    }
                } label: {
                    ///IN IOS 26 GLASS  EFFECT
                    if #available(iOS 26.0, *){
                        Text("Close")
                            .frame(width:100,height:40)
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(.black)
                            .glassEffect()
                            .padding(15)
                        
                        /// IN IOS 15  ULTRATHIN MATERAL AVALIABLE
                    } else if #available(iOS 15.0,*){
                        Text("Close")
                            .frame(width:100,height:40)
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(.black)
                            .background(.ultraThinMaterial,in: RoundedRectangle(cornerRadius: 15))
                            .padding(15)
                        /// IN NORMAL IN 14 BELOW
                        
                    }else{
                        Text("Close")
                            .frame(width:100,height:40)
                            .font(.system(size: 16))
                            .bold()
                            .foregroundColor(.black)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius:15))
                            .padding(15)
                        
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .overlay {
                Text("Details")
                    .font(.callout)
                    .fontWeight(.semibold)
            }
            .opacity(showContent ? 1 : 0)

            ZStack {

                // MARK: Card
                VStack {
                    Spacer().frame(height: 125)

                    VStack(alignment: .leading, spacing: 12) {

                        Text(item.name)
                            .font(.system(size: 20).bold())
                            .offset(y: -5)

                        Text(item.description)
                            .font(.system(size: 18))
                        
//                        HStack {
//                            Text("Quantity:").bold()
//                            Spacer()
//
//                            Button { decrement() } label: {
//                                Image(systemName: "minus.circle.fill")
//                            }
//                            .disabled(quantity == 1)
//
//                            Text("\(quantity)").bold()
//
//                            Button { increment() } label: {
//                                Image(systemName: "plus.circle.fill")
//                            }
//                            .disabled(quantity == 10)
//                        }
//                        .padding(.top, 10)

                        HStack {
                            Text("₹\(totalPrice)").bold()
                            Spacer()

//                            Button { } label: {
//                                Text("Add to Cart")
//                                    .padding(.vertical, 8)
//                                    .padding(.horizontal, 16)
//                                    .background(Color.blue)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(15)
//                            }
                            // Preparation Time Text
                            Text("Preparation Time: 15–20 mins")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                                .padding(.top, 8)

                        }
                        .padding(.top, 20)

                    }
                    .padding()
                }
                .frame(width: 360, height: 400)
                .background()
                .cornerRadius(20)
                .shadow(radius: 15)
                .offset(y: showContent ? 200 : 900)

                // MARK: PRODUCT IMAGE
                if item.isDrink {

                    // DRINK SPLIT ANIMATION IN BOTTLE
                    ZStack {

                        // LEFT BOTTLE
                        Image(item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .rotationEffect(.degrees(start ? -25 : 0), anchor: .bottom)
                            .offset(x: start ? 15 : 0, y: start ? -15 : 0)
                            .opacity(start ? 1 : 0)

                        // RIGHT BOTTLE
                        Image(item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .rotationEffect(.degrees(start ? 25 : 0), anchor: .bottom)
                            .offset(x: start ? -15 : 0, y: start ? -15 : 0)
                            .opacity(start ? 1 : 0)

                        // CENTER BOTTLE (MATCHED)
                        ZStack {
                            Image(item.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .matchedGeometryEffect(id: item.id, in: animation)
                        }

                    }
                    .frame(height: UIScreen.main.bounds.height / 3)
                    .offset(y: -30)

                } else {

                    // NORMAL ITEM (MATCHED)
                    ZStack {
                        Image(item.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .matchedGeometryEffect(id: item.id, in: animation) 
                    }
                    .frame(width: 300, height: 300) // controlled size image
                    .offset(y: 10)
                }

            }
        }
//        .scrollDismissesKeyboard(.interactively)
//        .ignoresSafeArea(.keyboard, edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white.opacity(0.01))
//        .onAppear {
//            withAnimation(.easeInOut.delay(0.1)) {
//                showContent = true
//            }
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.9).delay(0.1)) {
                        showContent = true
                    }
            ///DRINK ANIATION
            if item.isDrink {
                withAnimation(.spring().delay(0.15)) {
                    start = true
                }
            }
        }
    }

    // MARK: Quantity Handlers
    private func decrement() { quantity = max(quantity - 1, 1) }
    private func increment() { quantity = min(quantity + 1, 10) }
    private var totalPrice: Int { quantity * item.price }
}
//#Preview{
//    Home()
//}
