import SwiftUI
import MapKit

struct PowerStation: Identifiable {
    let id = UUID()
    let name: String
    let capacity: Int // Watt-hours
    let pricePerDay: Double
    let imageURL: String
    let location: String
    let coordinate: CLLocationCoordinate2D
}

struct ExploreView: View {
    @State private var searchText = ""
    @State private var showingAddListing = false
    @State private var showingMapView = false
    
    // Sample data - will be replaced with Supabase data
    let sampleStations = [
        PowerStation(
            name: "Jackery Explorer 1000",
            capacity: 1002,
            pricePerDay: 45.0,
            imageURL: "jackery1000",
            location: "San Francisco, CA",
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        ),
        PowerStation(
            name: "EcoFlow Delta Pro",
            capacity: 3600,
            pricePerDay: 89.0,
            imageURL: "ecoflow-delta",
            location: "Oakland, CA",
            coordinate: CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.2711)
        ),
        PowerStation(
            name: "Goal Zero Yeti 1500X",
            capacity: 1516,
            pricePerDay: 65.0,
            imageURL: "goalzero1500",
            location: "Berkeley, CA",
            coordinate: CLLocationCoordinate2D(latitude: 37.8715, longitude: -122.2730)
        )
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Search bar
                    searchBar
                    
                    if showingMapView {
                        // Map placeholder
                        Color(.systemGray6)
                            .overlay(
                                Text("Map View")
                                    .foregroundColor(.gray)
                            )
                    } else {
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
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showingMapView.toggle() }) {
                            Image(systemName: showingMapView ? "list.bullet" : "map")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(24)
                    }
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

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
