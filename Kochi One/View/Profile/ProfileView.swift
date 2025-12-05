import SwiftUI
import PhotosUI // Keep this import for a robust profile view experience

struct ProfileView: View {
    // REQUIRED BINDINGS
    @Binding var profileView: Bool // To dismiss the sheet
    @Binding var userProfileImage: UIImage? // The image passed from BottomBarView
    @Binding var userName: String

    // LOCAL STATE
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingImagePicker: Bool = false
    @State private var localName: String = ""
    @State private var localImage: UIImage? = nil
    @State private var hasUnsavedChanges: Bool = false
    @State private var showingDeleteAlert: Bool = false

    @State private var isNotificationsEnabled: Bool = true
    
    // Static / Mock Data for display
    let appVersion = "1.0.3 (42)"
    
    init(profileView: Binding<Bool>, userProfileImage: Binding<UIImage?>, userName: Binding<String>) {
        self._profileView = profileView
        self._userProfileImage = userProfileImage
        self._userName = userName
        
        let deviceId = DeviceIDManager.shared.deviceId
        _viewModel = StateObject(wrappedValue: ProfileViewModel(deviceId: deviceId))
    }

    var body: some View {
        NavigationView {
            ZStack {
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
                            .disabled(viewModel.isLoading)

                            // Editable Name Field
                            HStack {
                                TextField("Enter Name", text: $localName)
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .onChange(of: localName) { oldValue, newValue in
                                        hasUnsavedChanges = true
                                    }
                            }
                            .padding(.horizontal)
                            
                            // Error message
                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                            }
                            
                            // Save indicator
                            if hasUnsavedChanges && !viewModel.isLoading {
                                Text("Tap Save to update profile")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.top, 4)
                            }
                        }
                        .frame(maxWidth: .infinity) // Center the VSTack content
                        .padding(.vertical, 10)
                    }
                    .listRowBackground(Color.clear) // Hide the background of this section row
                
                    // MARK: - 2. App Features Section
                    Section("Settings & Actions") {
                        
                        // Favourites Button
                        NavigationLink(destination: FavouritesView()) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("My Favourites")
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
                        
                        // Delete Profile Button
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                                Text("Delete Profile")
                                    .foregroundColor(.red)
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
                            profileView = false
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if hasUnsavedChanges {
                            Button("Save") {
                                Task {
                                    await saveProfile()
                                }
                            }
                            .disabled(viewModel.isLoading)
                        }
                    }
                }
                .sheet(isPresented: $showingImagePicker) {
                    // The ImagePicker must be available in your project
                    ImagePicker(selectedImage: $localImage)
                }
                .onChange(of: localImage) { oldValue, newValue in
                    if newValue != nil {
                        hasUnsavedChanges = true
                        viewModel.selectedImage = newValue
                    }
                }
                .task {
                    // Load profile on appear
                    await viewModel.loadProfile()
                    
                    // Initialize local state from loaded profile
                    if let profile = viewModel.profile {
                        localName = profile.fullName
                        localImage = viewModel.profileImage
                        
                        // Update bindings
                        userName = profile.fullName
                        userProfileImage = viewModel.profileImage
                    } else {
                        // If no profile exists, use current bindings
                        localName = userName
                        localImage = userProfileImage
                    }
                }
                .alert("Delete Profile", isPresented: $showingDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        Task {
                            let success = await viewModel.deleteProfile()
                            if success {
                                localName = ""
                                localImage = nil
                                userName = ""
                                userProfileImage = nil
                                hasUnsavedChanges = false
                            }
                        }
                    }
                } message: {
                    Text("Are you sure you want to delete your profile? This action cannot be undone.")
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .overlay {
                            ProgressView()
                                .scaleEffect(1.5)
                        }
                }
            }
        }
    }
    
    // MARK: - Helper Views & Methods
    
    @ViewBuilder
    private var profileImage: some View {
        if let image = localImage ?? viewModel.profileImage {
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
    
    // MARK: - Save Profile
    private func saveProfile() async {
        if viewModel.profile == nil {
            // Create new profile
            let success = await viewModel.createProfile(fullName: localName)
            if success {
                hasUnsavedChanges = false
                userName = localName
                userProfileImage = localImage ?? viewModel.profileImage
            }
        } else {
            // Update existing profile
            let success = await viewModel.updateProfile(fullName: localName)
            if success {
                hasUnsavedChanges = false
                userName = localName
                userProfileImage = localImage ?? viewModel.profileImage
            }
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
