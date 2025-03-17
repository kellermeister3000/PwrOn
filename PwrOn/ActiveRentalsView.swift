import SwiftUI

enum RentalMode {
    case renting
    case lending
}

struct ActiveRental: Identifiable {
    let id = UUID()
    let powerStationName: String
    let startDate: Date
    let endDate: Date
    let totalPrice: Double
    let status: String
}

struct ListedPowerStation: Identifiable {
    let id = UUID()
    let name: String
    let isRented: Bool
    let currentRental: ActiveRental?
    let pricePerDay: Double
}

struct ActiveRentalsView: View {
    @State private var mode: RentalMode = .renting
    
    // Sample data
    let rentals = [
        ActiveRental(
            powerStationName: "Jackery Explorer 1000",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 3),
            totalPrice: 135.0,
            status: "Active"
        ),
        ActiveRental(
            powerStationName: "EcoFlow Delta",
            startDate: Date().addingTimeInterval(-86400 * 2),
            endDate: Date().addingTimeInterval(86400),
            totalPrice: 178.0,
            status: "Due Tomorrow"
        )
    ]
    
    let listedStations = [
        ListedPowerStation(
            name: "Goal Zero Yeti 1500X",
            isRented: true,
            currentRental: ActiveRental(
                powerStationName: "Goal Zero Yeti 1500X",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 4),
                totalPrice: 260.0,
                status: "Rented"
            ),
            pricePerDay: 65.0
        ),
        ListedPowerStation(
            name: "Bluetti AC200P",
            isRented: false,
            currentRental: nil,
            pricePerDay: 55.0
        )
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Rental Mode", selection: $mode) {
                    Text("Renting").tag(RentalMode.renting)
                    Text("Lending").tag(RentalMode.lending)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if mode == .renting {
                    rentingView
                } else {
                    lendingView
                }
            }
            .navigationTitle("My Rentals")
        }
    }
    
    private var rentingView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(rentals) { rental in
                    RentalCard(rental: rental)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
    
    private var lendingView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(listedStations) { station in
                    ListedStationCard(station: station)
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
}

struct RentalCard: View {
    let rental: ActiveRental
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(rental.powerStationName)
                .font(.headline)
            
            HStack {
                Label(
                    DateFormatter.shortDate.string(from: rental.startDate),
                    systemImage: "calendar")
                Text("→")
                Label(
                    DateFormatter.shortDate.string(from: rental.endDate),
                    systemImage: "calendar")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            HStack {
                Text(rental.status)
                    .font(.caption)
                    .padding(6)
                    .background(rental.status == "Active" ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Text("$\(String(format: "%.2f", rental.totalPrice))")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct ListedStationCard: View {
    let station: ListedPowerStation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(station.name)
                    .font(.headline)
                
                Spacer()
                
                Text(station.isRented ? "Rented" : "Available")
                    .font(.caption)
                    .padding(6)
                    .background(station.isRented ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                    .cornerRadius(4)
            }
            
            HStack {
                Image(systemName: "dollarsign.circle")
                Text("\(String(format: "%.2f", station.pricePerDay))/day")
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            
            if let rental = station.currentRental {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Rental Period")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Start")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(DateFormatter.shortDate.string(from: rental.startDate))
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("End")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(DateFormatter.shortDate.string(from: rental.endDate))
                                .font(.subheadline)
                        }
                    }
                    
                    Text("Total: $\(String(format: "%.2f", rental.totalPrice))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}

#Preview {
    ActiveRentalsView()
}
