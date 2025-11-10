import SwiftUI
import PhotosUI // Keep this import for a robust profile view experience

struct ProfileView: View {
    // REQUIRED BINDINGS
    @Binding var profileView: Bool // To dismiss the sheet
    @Binding var userProfileImage: UIImage? // The image passed from BottomBarView
    @Binding var userName: String

    // LOCAL STATE
    @State private var showingImagePicker: Bool = false
    @State private var selectedProfileImage: UIImage? = nil // Local image copy for editing

    @State private var isNotificationsEnabled: Bool = true
    
    // Static / Mock Data for display
    let appVersion = "1.0.3 (42)"

    var body: some View {
        NavigationView {
            Form {
                // MARK: - 1. Profile Photo and Editable Name
                Section {
                    VStack(alignment: .center, spacing: 15) {
                        // Profile Image Button
                        Button {
                            showingImagePicker = true
                        } label: {
                            ZStack(alignment: .bottomTrailing) {
                                // Display selected image, or a placeholder
                                profileImage
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                
                                // Pencil icon to trigger image picker
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .offset(x: 5, y: 5)
                            }
                        }
                        .buttonStyle(.plain) // Remove default button styling

                        // Editable Name Field
                        HStack {
                            TextField("Enter Name", text: $userName)
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity) // Center the VSTack content
                    .padding(.vertical, 10)
                }
                .listRowBackground(Color.clear) // Hide the background of this section row
                
                // MARK: - 2. App Features Section
                Section("Settings & Actions") {
                    
                    // Favourites Button
                    Button(action: {
                        // Action: Navigate to Favourites View
                    }) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("My Favourites")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }

                    // Share App Button
                    Button(action: {
                        shareApp()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                                .foregroundColor(.green)
                            Text("Share Kochi One with Friends")
                            Spacer()
                        }
                    }
                    
                    // Notification Toggle
                    Toggle(isOn: $isNotificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.orange)
                            Text("Notifications")
                        }
                    }
                }
                
                // MARK: - 3. App Info Section
                Section("Support & Information") {
                    
                    // Check for Update Button
                    Button(action: {
                        checkForUpdate()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundColor(.purple)
                            Text("Check for App Update")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }

                    // App Version Details
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("App Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        // When closing, save the image back to the main app state
                        self.userProfileImage = self.selectedProfileImage
                        profileView = false
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                // The ImagePicker must be available in your project
                ImagePicker(selectedImage: $selectedProfileImage)
            }
            .onAppear {
                // Initialize local image state with the external binding value
                self.selectedProfileImage = self.userProfileImage
            }
        }
    }
    
    // MARK: - Helper Views & Methods
    
    @ViewBuilder
    private var profileImage: some View {
        if let image = selectedProfileImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            // Default placeholder icon
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
        }
    }
    
    private func shareApp() {
        // Placeholder for share action
        print("Share sheet triggered.")
        // In a real app, use UIActivityViewController or ShareLink here.
    }
    
    private func checkForUpdate() {
        // Placeholder for update check logic
        print("Checking for updates...")
        // In a real app, you would check an API or the App Store.
    }
}
