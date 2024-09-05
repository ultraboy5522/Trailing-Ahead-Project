import SwiftUI

struct ContentView: View {
    @State private var profile = Profile.load()
    @State private var showingProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background image with blur effect
                Image("Image Asset") // Use the name of the imported image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 5) // Apply blur effect
                
                // Content over the background
                VStack(spacing: 20) {
                    Text("Welcome to\nTrailing Ahead")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    if profile.isEmpty {
                        Button(action: {
                            showingProfile = true
                        }) {
                            Text("Create Profile")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showingProfile) {
                            ProfileView(profile: $profile, showingProfile: $showingProfile)
                        }
                    } else {
                        NavigationLink(destination: ProfileDetailView(profile: $profile)) {
                            Text("View Profile")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    NavigationLink(destination: FindBuddyView()) {
                        Text("Find a Hike")
                            .padding()
                            .background(Color.blue) // Match the color of the "Create Profile" button
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}

struct ProfileView: View {
    @Binding var profile: Profile
    @Binding var showingProfile: Bool
    @State private var name: String
    @State private var location: String
    @State private var interests: String
    @State private var image: UIImage?
    @State private var showingImagePicker = false
    
    init(profile: Binding<Profile>, showingProfile: Binding<Bool>) {
        self._profile = profile
        self._showingProfile = showingProfile
        _name = State(initialValue: profile.wrappedValue.name)
        _location = State(initialValue: profile.wrappedValue.location)
        _interests = State(initialValue: profile.wrappedValue.interests)
        _image = State(initialValue: profile.wrappedValue.image)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Name", text: $name)
                    TextField("Location", text: $location)
                    TextField("Interests", text: $interests)
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Text("Select Profile Photo")
                    }
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                    }
                }
                Button(action: {
                    profile.name = name
                    profile.location = location
                    profile.interests = interests
                    profile.image = image
                    profile.save()
                    showingProfile = false
                }) {
                    Text("Save Profile")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Create Profile")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $image)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingProfile = false
                    }
                }
            }
        }
    }
}

struct FindBuddyView: View {
    var body: some View {
        Text("Find a Hiking Buddy")
            .font(.largeTitle)
            .navigationTitle("Find Buddy")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Profile: Codable {
    var name: String
    var location: String
    var interests: String
    var imageData: Data?
    
    static let key = "UserProfile"
    
    var isEmpty: Bool {
        return name.isEmpty && location.isEmpty && interests.isEmpty
    }
    
    var image: UIImage? {
        get {
            guard let data = imageData else { return nil }
            return UIImage(data: data)
        }
        set {
            imageData = newValue?.jpegData(compressionQuality: 0.8)
        }
    }
    
    static func load() -> Profile {
        if let data = UserDefaults.standard.data(forKey: Profile.key),
           let profile = try? JSONDecoder().decode(Profile.self, from: data) {
            return profile
        }
        return Profile(name: "", location: "", interests: "")
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Profile.key)
        }
    }
}
