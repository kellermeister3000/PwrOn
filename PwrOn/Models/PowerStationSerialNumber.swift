import Foundation

// Supported manufacturer types
enum PowerStationManufacturer: String, CaseIterable {
    case goalZero = "Goal Zero"
    case jackery = "Jackery"
    case ecoFlow = "EcoFlow"
    case bluetti = "Bluetti"
    case unknown = "Unknown"
}

struct PowerStationSerialNumber {
    let rawValue: String
    let manufacturer: PowerStationManufacturer
    let modelNumber: String
    let serialNumber: String
    let manufacturingDate: Date?
    
    // Parsed information
    var capacity: Int? // In Watt-hours
    var productLine: String?
    var manufacturingLocation: String?
}

class SerialNumberParser {
    
    static func parse(_ input: String) -> PowerStationSerialNumber? {
        // Clean up input
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
                          .replacingOccurrences(of: " ", with: "")
                          .uppercased()
        
        // Try each manufacturer's pattern
        if let parsed = parseGoalZero(cleaned) {
            return parsed
        }
        if let parsed = parseJackery(cleaned) {
            return parsed
        }
        if let parsed = parseEcoFlow(cleaned) {
            return parsed
        }
        if let parsed = parseBluetti(cleaned) {
            return parsed
        }
        
        return nil
    }
    
    // Goal Zero format: YY-MM-XXXXX-PPP
    // YY: Year, MM: Month, XXXXX: Serial, PPP: Product
    private static func parseGoalZero(_ input: String) -> PowerStationSerialNumber? {
        let pattern = #"^(\d{2})-(\d{2})-(\d{5})-([A-Z0-9]{3})$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) else {
            return nil
        }
        
        // Extract components
        let year = String(input[Range(match.range(at: 1), in: input)!])
        let month = String(input[Range(match.range(at: 2), in: input)!])
        let serial = String(input[Range(match.range(at: 3), in: input)!])
        let product = String(input[Range(match.range(at: 4), in: input)!])
        
        // Create date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM"
        let date = dateFormatter.date(from: "\(year)-\(month)")
        
        return PowerStationSerialNumber(
            rawValue: input,
            manufacturer: .goalZero,
            modelNumber: product,
            serialNumber: serial,
            manufacturingDate: date
        )
    }
    
    // Jackery format: J-PPPP-YYWW-XXXX
    // PPPP: Product, YY: Year, WW: Week, XXXX: Serial
    private static func parseJackery(_ input: String) -> PowerStationSerialNumber? {
        let pattern = #"^J-([A-Z0-9]{4})-(\d{2})(\d{2})-(\d{4})$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) else {
            return nil
        }
        
        // Extract components
        let product = String(input[Range(match.range(at: 1), in: input)!])
        let year = String(input[Range(match.range(at: 2), in: input)!])
        let week = String(input[Range(match.range(at: 3), in: input)!])
        let serial = String(input[Range(match.range(at: 4), in: input)!])
        
        // Create date (approximate using week number)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-ww"
        let date = dateFormatter.date(from: "\(year)-\(week)")
        
        return PowerStationSerialNumber(
            rawValue: input,
            manufacturer: .jackery,
            modelNumber: product,
            serialNumber: serial,
            manufacturingDate: date
        )
    }
    
    // EcoFlow format: EF-PPPP-YYMM-XXXX
    // PPPP: Product, YY: Year, MM: Month, XXXX: Serial
    private static func parseEcoFlow(_ input: String) -> PowerStationSerialNumber? {
        let pattern = #"^EF-([A-Z0-9]{4})-(\d{2})(\d{2})-(\d{4})$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) else {
            return nil
        }
        
        // Extract components
        let product = String(input[Range(match.range(at: 1), in: input)!])
        let year = String(input[Range(match.range(at: 2), in: input)!])
        let month = String(input[Range(match.range(at: 3), in: input)!])
        let serial = String(input[Range(match.range(at: 4), in: input)!])
        
        // Create date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM"
        let date = dateFormatter.date(from: "\(year)-\(month)")
        
        return PowerStationSerialNumber(
            rawValue: input,
            manufacturer: .ecoFlow,
            modelNumber: product,
            serialNumber: serial,
            manufacturingDate: date
        )
    }
    
    // Bluetti format: BT-PPPP-YYMM-XXXX
    private static func parseBluetti(_ input: String) -> PowerStationSerialNumber? {
        let pattern = #"^BT-([A-Z0-9]{4})-(\d{2})(\d{2})-(\d{4})$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) else {
            return nil
        }
        
        // Extract components
        let product = String(input[Range(match.range(at: 1), in: input)!])
        let year = String(input[Range(match.range(at: 2), in: input)!])
        let month = String(input[Range(match.range(at: 3), in: input)!])
        let serial = String(input[Range(match.range(at: 4), in: input)!])
        
        // Create date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM"
        let date = dateFormatter.date(from: "\(year)-\(month)")
        
        return PowerStationSerialNumber(
            rawValue: input,
            manufacturer: .bluetti,
            modelNumber: product,
            serialNumber: serial,
            manufacturingDate: date
        )
    }
}

// MARK: - Usage Example
extension SerialNumberParser {
    static func example() {
        // Goal Zero example: 23-06-12345-Y40
        let goalZeroSerial = "23-06-12345-Y40"
        if let parsed = SerialNumberParser.parse(goalZeroSerial) {
            print("Manufacturer: \(parsed.manufacturer.rawValue)")
            print("Model: \(parsed.modelNumber)")
            print("Serial: \(parsed.serialNumber)")
            print("Date: \(parsed.manufacturingDate?.description ?? "Unknown")")
        }
        
        // Jackery example: J-1000-2306-0001
        let jackerySerial = "J-1000-2306-0001"
        if let parsed = SerialNumberParser.parse(jackerySerial) {
            print("Manufacturer: \(parsed.manufacturer.rawValue)")
            print("Model: \(parsed.modelNumber)")
            print("Serial: \(parsed.serialNumber)")
            print("Date: \(parsed.manufacturingDate?.description ?? "Unknown")")
        }
    }
}