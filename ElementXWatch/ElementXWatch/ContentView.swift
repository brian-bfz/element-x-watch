import SwiftUI
import Kingfisher
import KeychainAccess

struct ContentView: View {
    var body: some View {
        TabView {
            ChatListView()
                .tabItem {
                    Label("Chats", systemImage: "message")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct ChatListView: View {
    let rooms = [
        ChatRoom(id: 1, name: "Matrix HQ", lastMessage: "Welcome to Matrix!", avatarURL: "https://matrix.org/images/matrix-logo-white.svg"),
        ChatRoom(id: 2, name: "Element Team", lastMessage: "How's the watchOS app coming?", avatarURL: "https://element.io/images/logo-mark-primary.svg"),
        ChatRoom(id: 3, name: "Rust SDK", lastMessage: "New release available", avatarURL: "https://matrix-org.github.io/matrix-rust-sdk/logo.png"),
        ChatRoom(id: 4, name: "Design Team", lastMessage: "Check out the new mockups", avatarURL: nil),
        ChatRoom(id: 5, name: "Community", lastMessage: "Thanks for your contribution!", avatarURL: nil)
    ]
    
    var body: some View {
        List(rooms) { room in
            HStack {
                if let avatarURL = room.avatarURL, let url = URL(string: avatarURL) {
                    KFImage(url)
                        .placeholder {
                            Circle().fill(.blue)
                        }
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(.blue)
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading) {
                    Text(room.name)
                        .font(.headline)
                    Text(room.lastMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Chats")
    }
}

struct SettingsView: View {
    @State private var username: String = ""
    @State private var isLoggedIn: Bool = false
    
    private let keychain = Keychain(service: "io.element.watch")
    
    var body: some View {
        List {
            Section {
                if isLoggedIn {
                    Text(username)
                        .font(.caption)
                } else {
                    Text("Not logged in")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Account")
            }
            
            Section {
                Toggle("Notifications", isOn: .constant(true))
                Toggle("Sync in Background", isOn: .constant(true))
            } header: {
                Text("Settings")
            }
            
            if !isLoggedIn {
                Section {
                    Button("Login") {
                        simulateLogin()
                    }
                }
            } else {
                Section {
                    Button("Logout") {
                        logout()
                    }
                    .foregroundStyle(.red)
                }
            }
            
            Section {
                Text("Element X Watch")
                Text("Version 1.0")
                    .font(.caption)
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            loadUserData()
        }
    }
    
    private func loadUserData() {
        if let savedUsername = try? keychain.get("username") {
            username = savedUsername
            isLoggedIn = true
        }
    }
    
    private func simulateLogin() {
        // In a real app, this would connect to the Matrix server
        username = "@demo:matrix.org"
        isLoggedIn = true
        
        // Save to keychain
        try? keychain.set(username, key: "username")
    }
    
    private func logout() {
        username = ""
        isLoggedIn = false
        
        // Clear keychain
        try? keychain.remove("username")
    }
}

struct ChatRoom: Identifiable {
    let id: Int
    let name: String
    let lastMessage: String
    let avatarURL: String?
}

#Preview {
    ContentView()
} 