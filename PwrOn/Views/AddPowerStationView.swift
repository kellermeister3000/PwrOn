import SwiftUI
import MapKit

struct AddPowerStationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var capacity = ""
    @State private var pricePerDay = ""
    @State private var location = ""
    @State private var showingScanner = false
    @State private var serialNumber = ""
    @State private var coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    @State private var parsedProduct: EcoFlowProduct?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Information") {
                    TextField("Name", text: $name)
                    TextField("Capacity (Wh)", text: $capacity)
                        .keyboardType(.numberPad)
                    TextField("Price per Day ($)", text: $pricePerDay)
                        .keyboardType(.decimalPad)
                }
                
                Section("Location") {
                    TextField("Location", text: $location)
                    Map(initialPosition: .region(MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))) {
                        Marker("Location", coordinate: coordinate)
                    }
                    .frame(height: 200)
                }
                
                Section("Serial Number") {
                    HStack {
                        TextField("Serial Number", text: $serialNumber)
                            .onChange(of: serialNumber) { _, newValue in
                                processSerialNumber(newValue)
                            }
                        Button(action: { showingScanner = true }) {
                            Image(systemName: "camera")
                        }
                    }
                    
                    if let product = parsedProduct, product.serialNumber == serialNumber {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Product: \(product.displayName)")
                                .foregroundColor(.primary)
                            Text("Manufactured: \(product.manufactureDateString)")
                                .foregroundColor(.secondary)
                            Text("Capacity: \(product.capacity) Wh")
                                .foregroundColor(.secondary)
                        }
                        .font(.footnote)
                    }
                }
            }
            .navigationTitle("New Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        // TODO: Add power station
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                ScannerView { scannedText in
                    processSerialNumber(scannedText)
                }
            }
        }
    }
    
    private func processSerialNumber(_ input: String) {
        serialNumber = input.trimmingCharacters(in: .whitespacesAndNewlines)
        parsedProduct = EcoFlowParser.parse(serialNumber: serialNumber)
        if let product = parsedProduct {
            name = product.displayName
            capacity = "\(product.capacity)"
        }
    }
}
