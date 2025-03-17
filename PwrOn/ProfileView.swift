import SwiftUI

struct UserProfile {
    var name: String
    var email: String
    var phoneNumber: String
    var joinDate: Date
}

struct ProfileView: View {
    // Sample user data - will be replaced with Supabase data
    let user = UserProfile(
        name: "John Doe",
        email: "john@example.com",
        phoneNumber: "(555) 123-4567",
        joinDate: Date().addingTimeInterval(-86400 * 90) // 90 days ago
    )
    
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Member since \(DateFormatter.monthYear.string(from: user.joinDate))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Account") {
                    LabeledContent("Email", value: user.email)
                    LabeledContent("Phone", value: user.phoneNumber)
                }
                
                Section {
                    NavigationLink("Payment Methods") {
                        Text("Payment Methods")
                    }
                    
                    NavigationLink("Notifications") {
                        Text("Notifications")
                    }
                }
                
                Section {
                    NavigationLink("Help & Support") {
                        Text("Help & Support")
                    }
                    
                    NavigationLink("Terms of Service") {
                        Text("Terms of Service")
                    }
                    
                    NavigationLink("Privacy Policy") {
                        Text("Privacy Policy")
                    }
                }
                
                Section {
                    Button("Sign Out", role: .destructive) {
                        // Sign out action
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        showingEditProfile.toggle()
                    }
                }
            }
        }
    }
}

extension DateFormatter {
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
}

#Preview {
    ProfileView()
}
