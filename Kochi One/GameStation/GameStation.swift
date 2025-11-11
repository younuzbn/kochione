//
//  ContentView.swift
//  Kochi One
//
//  Created by Subin Kurian on 11/11/25.
//


//
//  ContentView.swift
//  demo
//
//  Created by Subin Kurian on 10/11/25.
//

import SwiftUI

struct GameStation: View {
    @State private var showSheet = false

    var body: some View {

        VStack {
            Button("Open Sheet") {
                showSheet = true
            }
            .padding()
        }
        .sheet(isPresented: $showSheet) {
            PlayStationView()
                .presentationDetents([.height(700)])
                .presentationCornerRadius(30)
        }
    }
}

struct PlayStationView: View {
    
    ///  list address
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var date: Date = Date()
    @State private var time: Date = Date()
    
    ///Stepper  player count
    @State private var PlayerCount:Int = 1
    
    /// game list
    
    let games = ["FIFA 24", "Call of Duty", "Fortnite", "Marvel's Spider-Man 2", "God of War", "The Last of Us Part I"]
       @State private var selectedGame: String = "Call of Duty"
       @State private var selectedGamesList: [String] = []

    var body: some View {
            ScrollView(.vertical) {
                VStack(spacing: 20) {

                    //  ✅ PARALLAX CAROUSEL
                    GeometryReader { geometry in
                        let size = geometry.size

                        ScrollView(.horizontal) {
                            HStack(spacing: 5) {
                                ForEach(card) { card in
                                    GeometryReader { proxy in
                                        let cardSize = proxy.size
                                        let minX = min((proxy.frame(in: .scrollView).minX - 30.0) * 1.4,
                                                       size.width * 1.4)

                                        Image(card.image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .offset(x: -minX)
                                            .frame(width: proxy.size.width * 2.5)
                                            .frame(width: cardSize.width, height: cardSize.height)
                                            .overlay {
                                                OverlayView(card)
                                            }
                                            .clipShape(.rect(cornerRadius: 15))
                                            .shadow(color: .black.opacity(0.25),
                                                    radius: 8, x: 5, y: 10)
                                    }
                                    .frame(width: size.width - 60, height: size.height - 50)
                                    .scrollTransition(.interactive, axis: .horizontal) { view, phase in
                                        view.scaleEffect(phase.isIdentity ? 1 : 0.95)
                                    }
                                }
                            }
                            .padding(.horizontal, 30)
                            .scrollTargetLayout()
                            .frame(height: size.height, alignment: .top)
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .scrollIndicators(.hidden)
                    }
                    .frame(height: 500)
                    .padding(.horizontal, -15)
                    .padding(.top, 10)



                /// group the all details

                    Group {
                        TextField("Enter Name", text: $name)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

//                        TextField("Enter Address", text: $address)
//                            .padding()
//                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        TextField("Enter Phone Number", text: $phoneNumber)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                        DatePicker("Select Date", selection: $date, displayedComponents: .date)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                        DatePicker("Select Time", selection: $time, displayedComponents: .hourAndMinute)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }


                   
                    HStack {
                        Picker("Select Game", selection: $selectedGame) {
                            ForEach(games, id: \.self) { game in
                                Text(game)
                            }
                        }

                        Spacer()

                        Button {
                            
                            if !selectedGamesList.contains(selectedGame) {
                                selectedGamesList.append(selectedGame)
                               }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))


                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(selectedGamesList.indices, id: \.self) { index in
                            HStack {
                                Text(selectedGamesList[index])
                                    .font(.headline)

                                Spacer()

                                Button {
                                    selectedGamesList.remove(at: index)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                            }
                            .padding()
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    /// count players
                    Stepper("Players Count: \(PlayerCount)", value: $PlayerCount, in: 1...4)
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    Button {
                      print("Btn Tapped")
                    } label: {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                        
                    }

                    
                    
                }
                .padding(15)
            }
            .scrollIndicators(.hidden)
        }


    /// Overlay Text on Image
    @ViewBuilder
    func OverlayView(_ card: Cards) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [
                .clear,
                .clear,
                .clear,
                .clear,
                .black.opacity(0.3),
                .black.opacity(0.6),
                .black
            ], startPoint: .top, endPoint: .bottom)

            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(card.subtitle)
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(20)
        }
    }
}

#Preview {
    GameStation()
}
