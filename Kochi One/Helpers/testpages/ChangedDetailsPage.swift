////
////  ChangedDetailsPage.swift
////  Kochi One
////
////  Created by Muhammed Younus on 25/11/25.
////
//
//
////
////  ChangedDetailsPage.swift
////  Kochi One
////
////  Created by Adarsh on 20/11/25.
////
//
//
//import SwiftUI
//
//struct ChangedDetailsPage: View {
//    
//    let restaurant: Restaurant
//    @ObservedObject var locationService: LocationService
//    let onBack: () -> Void
//    @ObservedObject private var favouritesManager = FavouritesManager.shared
//    @State private var showCallDialog = false
//    @State private var showMapPicker = false
//    @State private var showEmailDialog = false
//    @State private var showWebsiteDialog = false
//    @State private var showShareDialog = false
//    @State private var heartScale: CGFloat = 1.0
//    
//    var operatingHours: OperatingHours {
//        restaurant.operatingHours
//    }
//    
//    //    var todayData: (isClosed: Bool, opening: String, closing: String) { getTodayHours() }
//    //    var storeOpen: Bool {
//    //        if todayData.isClosed { return false }
//    //        return isStoreOpen(opening: todayData.opening, closing: todayData.closing)
//    //    }
//    var body: some View {
//        let days: [(String, DayHours)] = [
//            ("Monday", operatingHours.monday),
//            ("Tuesday", operatingHours.tuesday),
//            ("Wednesday", operatingHours.wednesday),
//            ("Thursday", operatingHours.thursday),
//            ("Friday", operatingHours.friday),
//            ("Saturday", operatingHours.saturday),
//            ("Sunday", operatingHours.sunday)
//        ]
//        let todayData = getTodayHours(from: operatingHours)
//        
//        ZStack(alignment: .top) {
//            ScrollView(showsIndicators:false) {
//               
//                ZStack(alignment:.top) {
//                VStack{
//                    ZStack(alignment: .bottom) {
//                        
//                        // Background Image
//                        
////                        CachedAsyncImage(url: restaurant.coverImages.first?.url ?? "") { image in
////                            image
////                                .resizable()
////                                .aspectRatio(contentMode: .fill)
////                                .frame(width: 45, height: 45)
////                                .clipShape(Circle())
////                        } placeholder: {
////                            Circle()
////                                .fill(.fill)
////                                .frame(width: 45, height: 45)
////                        }
//                        if let firstImage = restaurant.coverImages.first,
//                           let url = URL(string: firstImage.url) {
//                            AsyncImage(url: url) { phase in
//                                switch phase {
//                                case .empty:
//                                    ProgressView()
//                                        
//                                        .frame(height: 300)
//                                        
//                                case .success(let image):
//                                    image
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(height: 300)
//                                        .clipped()
//                                    
//                                    
//                                case .failure:
//                                    RoundedRectangle(cornerRadius: 15)
//                                    //                            .fill(Color.gray.opacity(0.2))
//                                        .frame(height: 300)
//                                        .overlay(Text("No Image").foregroundStyle(.gray))
//                                @unknown default:
//                                    EmptyView()
//                                }
//                            }
//                        } else {
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(Color.gray.opacity(0.2))
//                                .frame(width: 300, height: 150)
//                                .overlay(Text("No Image").foregroundStyle(.gray))
//                        }
//                        
//                        // Card overlay
//                        VStack{
//                            VStack(alignment: .leading, spacing: 10) {
//                                
//                                
//                                
//                                
//                                HStack {
//                                    Text(restaurant.name)
//                                        .font(.system(size: 18))
//                                        .bold()
//                                    Spacer()
//                                }
//                                HStack {
//                                    Text(restaurant.restaurantType ?? "")
//                                        .font(.system(size: 14))
//                                        .foregroundStyle(.gray)
//                                    Spacer()
//                                }
//                                Divider()
//                                HStack{
//                                    Image(systemName: "location.fill")
//                                        .foregroundStyle(.gray)
//                                    Text("\(restaurant.address.street),\(restaurant.address.city)")
//                                        .font(.system(size: 12))
//                                        .foregroundStyle(.gray)
//                                }
//                                HStack{
//                                    Image(systemName:"clock.fill")
//                                        .foregroundStyle(.gray)
//                                    Text(locationService.calculateDistance(to: restaurant))
//                                        .font(.system(size: 12))
//                                        .foregroundStyle(.gray)
//                                    RoundedRectangle(cornerRadius: 15)
//                                        .frame(width: 5,height: 5)
//                                    if todayData.isOpen {
//                                        
//                                        Text("Open")
//                                            .font(.system(size: 13))
//                                            .bold()
//                                        .foregroundStyle(.green)
//                                        RoundedRectangle(cornerRadius: 15)
//                                            .frame(width: 5,height: 5)
//                                        Text("Open until :\(convertTo12Hour(todayData.hours.close ?? ""))")
//                                            .font(.system(size: 12))
//                                            .foregroundStyle(.gray)
//                                        
//                                          } else {
//                                              Text("Closed")
//                                            .foregroundStyle(.red)
//                                            .font(.system(size: 13))
//                                          }
//                                }
//                                
//                                // Action buttons inside card
//                                HStack {
//                                    Spacer()
//                                    
//                                    // Call Button
//                                    Button {
//                                        showCallDialog = true
//                                    } label: {
//                                        Image(systemName: "phone.fill")
//                                            .font(.system(size: 18))
//                                            .foregroundStyle(.black)
//                                    }
//                                    .confirmationDialog("Call \(restaurant.name)?", isPresented: $showCallDialog, titleVisibility: .visible) {
//                                        Button("Call") {
//                                            let phoneNumber = restaurant.contact.phone
//                                            guard !phoneNumber.isEmpty else {
//                                                print("Phone number is empty")
//                                                return
//                                            }
//                                            
//                                            let cleanedNumber = phoneNumber
//                                                .replacingOccurrences(of: " ", with: "")
//                                                .replacingOccurrences(of: "-", with: "")
//                                                .replacingOccurrences(of: "(", with: "")
//                                                .replacingOccurrences(of: ")", with: "")
//                                                .replacingOccurrences(of: ".", with: "")
//                                            
//                                            if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
//                                                if UIApplication.shared.canOpenURL(phoneURL) {
//                                                    UIApplication.shared.open(phoneURL)
//                                                }
//                                            }
//                                        }
//                                        Button("Cancel", role: .cancel) { }
//                                    } message: {
//                                        Text(restaurant.contact.phone.isEmpty ? "No phone number available" : restaurant.contact.phone)
//                                    }
//                                    
//                                    Spacer()
//                                    
//                                    // Navigation Button
//                                    Button {
//                                        let availableApps = MapApp.availableApps()
//                                        if availableApps.count == 1, let app = availableApps.first {
//                                            if let url = app.navigationURL(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude, businessName: restaurant.name) {
//                                                UIApplication.shared.open(url)
//                                            }
//                                        } else {
//                                            showMapPicker = true
//                                        }
//                                    } label: {
//                                        Image(systemName: "location.fill")
//                                            .font(.system(size: 18))
//                                            .foregroundStyle(.black)
//                                    }
//                                    .confirmationDialog("Choose Navigation App", isPresented: $showMapPicker, titleVisibility: .visible) {
//                                        ForEach(MapApp.availableApps()) { app in
//                                            Button(app.rawValue) {
//                                                if let url = app.navigationURL(latitude: restaurant.location.latitude, longitude: restaurant.location.longitude, businessName: restaurant.name) {
//                                                    UIApplication.shared.open(url)
//                                                }
//                                            }
//                                        }
//                                        Button("Cancel", role: .cancel) { }
//                                    }
//                                    
//                                    Spacer()
//                                    
//                                    // Email Button
//                                    Button {
//                                        showEmailDialog = true
//                                    } label: {
//                                        Image(systemName: "envelope.fill")
//                                            .font(.system(size: 18))
//                                            .foregroundStyle(.black)
//                                    }
//                                    .confirmationDialog("Email \(restaurant.name)?", isPresented: $showEmailDialog, titleVisibility: .visible) {
//                                        Button("Email") {
//                                            let email = restaurant.contact.email
//                                            guard !email.isEmpty else {
//                                                print("Email is empty")
//                                                return
//                                            }
//                                            
//                                            if let emailURL = URL(string: "mailto:\(email)") {
//                                                if UIApplication.shared.canOpenURL(emailURL) {
//                                                    UIApplication.shared.open(emailURL)
//                                                }
//                                            }
//                                        }
//                                        Button("Cancel", role: .cancel) { }
//                                    } message: {
//                                        Text(restaurant.contact.email.isEmpty ? "No email available" : restaurant.contact.email)
//                                    }
//                                    
//                                    Spacer()
//                                    
//                                    // Website Button
//                                    Button {
//                                        showWebsiteDialog = true
//                                    } label: {
//                                        Image(systemName: "safari")
//                                            .font(.system(size: 18))
//                                            .foregroundStyle(.black)
//                                    }
//                                    .confirmationDialog("Open Website?", isPresented: $showWebsiteDialog, titleVisibility: .visible) {
//                                        if let website = restaurant.contact.website, !website.isEmpty {
//                                            Button("Open Website") {
//                                                let urlString = website.hasPrefix("http") ? website : "https://\(website)"
//                                                if let url = URL(string: urlString) {
//                                                    UIApplication.shared.open(url)
//                                                }
//                                            }
//                                        }
//                                        Button("Cancel", role: .cancel) { }
//                                    } message: {
//                                        if let website = restaurant.contact.website, !website.isEmpty {
//                                            Text(website)
//                                        } else {
//                                            Text("No website available")
//                                        }
//                                    }
//                                    
//                                    Spacer()
//                                }
//                                .padding(.top, 8)
//                            }
//                            .padding()
//                            .frame(width: UIScreen.main.bounds.width - 40)
//                            .background()
//                            .cornerRadius(20)
//                            .shadow(radius: 4)
//                            .offset(y: 100)
//                            
//                        }
//                        .frame(height: 200)
//                        
//                        
//                        // overlaps downwards for the floating effect
//                    }
//                    
//                    .padding(.bottom, 40) // space for offset
//                    
//                    VStack(alignment: .leading, spacing: 12) {
//                       
//                        
//                        HStack {
//                            
//                            Text("About")
//                                .font(.system(size: 20, weight:.semibold))
//                                .padding(.leading,30)
//                            Spacer()
//                        }
//                        
//                        ////text
//                        Text(restaurant.description)
//                            .font(.system(size: 16))
//                            .padding(.horizontal, 30)
//                    }
//                    .padding(.top,60)
//                    .padding(.vertical,10)
//                    
//                    
//                    
//                    VStack {
//                        HStack {
//                            Text("Gallery")
//                                .font(.system(size: 16, weight: .semibold))
//                            
//                            Spacer()
//                            
//                            Button {
//                                print("Button tapped")
//                            } label: {
//                                Text("View All")
//                                    .font(.system(size: 16, weight: .semibold))
//                            }
//                            
//                        }
//                        
//                        
//                        ////image width
//                        
//                        
//                        LazyVGrid(
//                            columns: [
//                                GridItem(.flexible(), spacing: 10),
//                                GridItem(.flexible(), spacing: 10)
//                            ],
//                            spacing: 10
//                        ) {
//                            ForEach(restaurant.coverImages.dropFirst() ?? [], id: \.id){ media in
//                                if let url = URL(string: media.url) {
//                                    AsyncImage(url: url) { phase in
//                                        switch phase {
//                                        case .empty:
//                                            ProgressView()
//                                                .frame(width: 200, height: 150)
//                                        case .success(let image):
//                                            image
//                                                .resizable()
//                                                .scaledToFill()
//                                            ////images in 2x2 in correct position
//                                                .frame(width: (UIScreen.main.bounds.width - 40 - 40) / 2, height: 150)
//                                                .clipped()
//                                                .cornerRadius(10)
//                                        case .failure:
//                                            RoundedRectangle(cornerRadius: 15)
//                                                .fill(Color.gray.opacity(0.2))
//                                                .frame(width: 200, height: 150)
//                                                .overlay(Text("No Image").foregroundStyle(.gray))
//                                        @unknown default:
//                                            EmptyView()
//                                        }
//                                    }
//                                }
//                            }
//                            
//                            
//                            
//                            //
//                            
//                        }
//                        VStack(alignment:.leading){
//                            HStack{
//                                if todayData.isOpen{
//                                    
//                                    Image(systemName: "clock.fill")
//                                        .foregroundStyle(.green)
//                                        .bold()
//                                        .font(.system(size: 14))
//                                    Text("Open")
//                                        .foregroundColor(.green)
//                                        .bold()
//                                        .font(.system(size: 14))
//                                    Text(" Today closes at: \(convertTo12Hour(todayData.hours.close ?? ""))")
//                                        .font(.system(size: 14))
//                                        .foregroundStyle(.gray)
//                                    
//                                }
//                                else{
//                                    
//                                    Image(systemName: "clock.fill")
//                                        .foregroundStyle(.red)
//                                        .font(.system(size: 20))
//                                    Text("Closed")
//                                        .foregroundColor(.red)
//                                        .bold()
//                                        .font(.system(size: 14))
//                                }
//                                Spacer()
//                            }
//                            ForEach(days, id: \.0) { day, hours in
//                                    HStack {
//                                        Text(day.capitalized)
//                                            .frame(width: 120, alignment: .leading)
//
//                                        if hours.closed {
//                                            Text("Closed")
//
//                                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                        } else {
//                                            Text("\(convertTo12Hour(hours.open ?? "-")) - \(convertTo12Hour(hours.close ?? "-"))")
//                                                .frame(maxWidth: .infinity, alignment: .trailing)
//                                        }
//                                    }
//                                }
//                            VStack {
//                                HStack {
//                                    Image("Location")
//                                    Text("\(restaurant.address.city),\(restaurant.address.state),\(restaurant.address.state),\(restaurant.address.zipCode)")
//                                    Spacer()
//                                }
//                                HStack {
//                                    Image(systemName: "phone.fill")
//                                        .foregroundStyle(.gray)
//                                    Text("\(restaurant.contact.phone)")
//                                    
//                                    Spacer()
//                                }
//
//                            }
//                            .padding(.top,10)
//                            
//                        }
//                        .padding(.top,10)
//                    }
//                    .padding(.horizontal,30)
//                    .padding(.bottom,50)
//                    
//                 
//                    
//                    }
//                }
//                .ignoresSafeArea()
//            }
//            
//            // Fixed buttons at the top
//            HStack {
//                //MARK: BACK BTN
//                Button(action: onBack) {
//                    HStack {
//                        if #available(iOS 26.0, *) {
//                            Image(systemName: "chevron.left")
//                                .foregroundStyle(Color.gray)
//                                .frame(width: 50,height: 50)
//                                .glassEffect()
//                                .cornerRadius(50)
//                        } else {
//                            // Fallback on earlier versions
//                            Image(systemName: "chevron.left")
//                                .foregroundStyle(Color.white)
//                                .frame(width: 50,height: 50)
                                    //                                .background(.ultraThinMaterial)
//                                .cornerRadius(50)
//                        }
//                    }
//                }
//                
//                //MARK: LIKE BTN
//                Spacer()
//                Button {
//                    // Toggle favourite with animation
//                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
//                        heartScale = 1.3
//                    }
//                    
//                    // Toggle favourite
//                    favouritesManager.toggleFavourite(restaurantID: restaurant.id)
//                    
//                    // Reset scale after animation
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
//                            heartScale = 1.0
//                        }
//                    }
//                } label: {
//                    if #available(iOS 26.0, *) {
//                        Image(systemName: favouritesManager.isFavourite(restaurantID: restaurant.id) ? "suit.heart.fill" : "suit.heart")
//                            .foregroundStyle(favouritesManager.isFavourite(restaurantID: restaurant.id) ? Color.red : Color.gray)
//                            .scaleEffect(heartScale)
//                            .frame(width: 50,height: 50)
//                            .glassEffect()
//                            .cornerRadius(50)
//                    } else {
//                        Image(systemName: favouritesManager.isFavourite(restaurantID: restaurant.id) ? "suit.heart.fill" : "suit.heart")
//                            .foregroundStyle(favouritesManager.isFavourite(restaurantID: restaurant.id) ? Color.red : Color.white)
//                            .scaleEffect(heartScale)
//                            .frame(width: 50,height: 50)
//                            .background(.ultraThinMaterial)
//                            .cornerRadius(50)
//                    }
//                }
//                
//                //MARK: SHARE BTN
//                Button {
//                    showShareDialog = true
//                } label: {
//                    if #available(iOS 26.0, *) {
//                        Image(systemName: "square.and.arrow.up")
//                            .foregroundStyle(Color.gray)
//                            .frame(width: 50,height: 50)
//                            .glassEffect()
//                            .cornerRadius(50)
//                    } else {
//                        Image(systemName: "square.and.arrow.up")
//                            .foregroundStyle(Color.white)
//                            .frame(width: 50,height: 50)
//                            .background(.ultraThinMaterial)
//                            .cornerRadius(50)
//                    }
//                }
//                .confirmationDialog("", isPresented: $showShareDialog, titleVisibility: .hidden) {
//                    Button("Share") {
//                        shareRestaurant()
//                    }
//                    
//                    Button("Report") {
//                        print("Report restaurant: \(restaurant.name)")
//                    }
//                    
//                    if let website = restaurant.contact.website, !website.isEmpty {
//                        Button("View Menu") {
//                            let urlString = website.hasPrefix("http") ? website : "https://\(website)"
//                            if let url = URL(string: urlString) {
//                                UIApplication.shared.open(url)
//                            }
//                        }
//                    }
//                    
//                    Button("Cancel", role: .cancel) { }
//                }
//                
//            }
//            .padding(30)
//            .padding(.top, 20)
//        }
//        
//        
//        
//        
//        
//  
//    }
//    //MARK: TIME TRACKER
//    func convertTo12Hour(_ time24: String) -> String {
//        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        formatter.locale = .init(identifier: "en_US_POSIX")
//
//        let outputFormatter = DateFormatter()
//        outputFormatter.dateFormat = "hh:mm a"
//        outputFormatter.locale = .init(identifier: "en_US_POSIX")
//
//        
//        
//        if let date = formatter.date(from: time24) {
//            return outputFormatter.string(from: date)
//        } else{
//            return "Invalid time"
//        }
//    }
//    func getTodayKey() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEE"
//        return formatter.string(from: Date()).lowercased()
//    }
//    func getTodayHours(from operatingHours: OperatingHours) -> (hours: DayHours, isOpen: Bool) {
//        let today = getTodayKey()
//
//        let todayHours: DayHours
//
//        switch today {
//        case "monday": todayHours = operatingHours.monday
//        case "tuesday": todayHours = operatingHours.tuesday
//        case "wednesday": todayHours = operatingHours.wednesday
//        case "thursday": todayHours = operatingHours.thursday
//        case "friday": todayHours = operatingHours.friday
//        case "saturday": todayHours = operatingHours.saturday
//        default: todayHours = operatingHours.sunday
//        }
//
//        
//        let open = !todayHours.closed &&
//                   isStoreOpen(opening: todayHours.open ?? "",
//                               closing: todayHours.close ?? "")
//        
//        return (todayHours, open)
//      
//    }
//    
//    func isStoreOpen(opening: String, closing: String) -> Bool {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        formatter.locale = .init(identifier: "en_US_POSIX")
//
//        guard let openTime = formatter.date(from: opening),
//              let closeTime = formatter.date(from: closing) else {
//            return false
//        }
//
//        let now = Date()
//        let calendar = Calendar.current
//
//        let todayOpen = calendar.date(
//            bySettingHour: calendar.component(.hour, from: openTime),
//            minute: calendar.component(.minute, from: openTime),
//            second: 0,
//            of: now
//        )!
//
//        let todayClose = calendar.date(
//            bySettingHour: calendar.component(.hour, from: closeTime),
//            minute: calendar.component(.minute, from: closeTime),
//            second: 0,
//            of: now
//        )!
//
//        return now >= todayOpen && now <= todayClose
//    }
//    
//    // Share restaurant function with deep link
//    private func shareRestaurant() {
//        // Create deep link URL with properly encoded restaurant biz_id
//        let encodedBizId = restaurant.bizId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? restaurant.bizId
//        let deepLinkURL = "kochione://restaurant?biz_id=\(encodedBizId)"
//        let shareText = "Check out \(restaurant.name)!\n\n\(restaurant.description)\n\nLocation: \(restaurant.address.street), \(restaurant.address.city)\n\n\(deepLinkURL)"
//        
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//              let window = windowScene.windows.first,
//              let rootViewController = window.rootViewController,
//              let url = URL(string: deepLinkURL) else {
//            return
//        }
//        
//        let activityViewController = UIActivityViewController(
//            activityItems: [shareText, url],
//            applicationActivities: nil
//        )
//        
//        // For iPad support
//        if let popover = activityViewController.popoverPresentationController {
//            popover.sourceView = rootViewController.view
//            popover.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
//            popover.permittedArrowDirections = []
//        }
//        
//        // Find the topmost view controller
//        var topController = rootViewController
//        while let presented = topController.presentedViewController {
//            topController = presented
//        }
//        
//        topController.present(activityViewController, animated: true)
//    }
//}
