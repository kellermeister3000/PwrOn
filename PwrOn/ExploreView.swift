import SwiftUI

struct PowerStation: Identifiable {
    let id = UUID()
    let name: String
    let capacity: Int // Watt-hours
    let pricePerDay: Double
    let imageURL: String
    let location: String
}

struct ExploreView: View {
    @State private var searchText = ""
    @State private var showingAddListing = false
    
    // Sample data - will be replaced with Supabase data
    let sampleStations = [
        PowerStation(name: "Jackery Explorer 1000", capacity: 1002, pricePerDay: 45.0, imageURL: "jackery1000", location: "San Francisco, CA"),
        PowerStation(name: "EcoFlow Delta Pro", capacity: 3600, pricePerDay: 89.0, imageURL: "ecoflow-delta", location: "Oakland, CA"),
        PowerStation(name: "Goal Zero Yeti 1500X", capacity: 1516, pricePerDay: 65.0, imageURL: "goalzero1500", location: "Berkeley, CA")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Power station list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(sampleStations) { station in
                            PowerStationCard(station: station)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Explore")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddListing.toggle() }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddListing) {
                Text("Add New Listing")
                    .navigationTitle("New Listing")
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search power stations", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
    }
}

struct PowerStationCard: View {
    let station: PowerStation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder image
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .aspectRatio(16/9, contentMode: .fit)
                .overlay(
                    Text("Image Placeholder")
                        .foregroundColor(.gray)
                )
                .cornerRadius(8)
            
            Text(station.name)
                .font(.headline)
            
            HStack {
                Image(systemName: "bolt.circle")
                Text("\(station.capacity) Wh")
                Spacer()
                Image(systemName: "location")
                Text(station.location)
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            Text("$\(String(format: "%.2f", station.pricePerDay))/day")
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    ExploreView()
}
