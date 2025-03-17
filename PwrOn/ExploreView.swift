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

struct MapViewRepresentable: UIViewRepresentable {
    let stations: [PowerStation]
    @Binding var selectedStation: PowerStation?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove existing annotations
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)
        
        // Add station annotations
        let annotations = stations.map { station -> MKPointAnnotation in
            let annotation = MKPointAnnotation()
            annotation.coordinate = station.coordinate
            annotation.title = station.name
            annotation.subtitle = "$\(String(format: "%.2f", station.pricePerDay))/day"
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            
            let identifier = "PowerStation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                let button = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = button
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation else { return }
            if let station = parent.stations.first(where: { $0.coordinate.latitude == annotation.coordinate.latitude && $0.coordinate.longitude == annotation.coordinate.longitude }) {
                parent.selectedStation = station
            }
        }
    }
}

struct ExploreView: View {
    @State private var searchText = ""
    @State private var showingAddListing = false
    @State private var showingMapView = false
    @State private var selectedStation: PowerStation?
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
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
                        Map(position: $position) {
                            UserAnnotation()
                            
                            ForEach(sampleStations) { station in
                                Marker(station.name, coordinate: station.coordinate)
                                    .tint(.blue)
                            }
                        }
                        .mapControls {
                            MapUserLocationButton()
                            MapCompass()
                        }
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
            .sheet(item: $selectedStation) { station in
                NavigationStack {
                    PowerStationCard(station: station)
                        .padding()
                        .navigationTitle("Power Station Details")
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    selectedStation = nil
                                }
                            }
                        }
                }
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
    @State private var showingMap = false
    
    var body: some View {
        Button(action: { showingMap = true }) {
            VStack(alignment: .leading, spacing: 8) {
                // Map preview
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: station.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))) {
                    Marker(station.name, coordinate: station.coordinate)
                        .tint(.blue)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .disabled(true)
                
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
        .buttonStyle(.plain)
        .sheet(isPresented: $showingMap) {
            NavigationStack {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: station.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))) {
                    Marker(station.name, coordinate: station.coordinate)
                        .tint(.blue)
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .navigationTitle(station.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showingMap = false }
                    }
                }
            }
        }
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
