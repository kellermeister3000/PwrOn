import Foundation

enum EcoFlowProduct {
    case deltaPro(serialNumber: String, manufactureDate: Date)
    case deltaMax(serialNumber: String, manufactureDate: Date)
    case delta2(serialNumber: String, manufactureDate: Date, modelCode: String)
    case delta2Max(serialNumber: String, manufactureDate: Date)
    case river2Pro(serialNumber: String, manufactureDate: Date)
    case river2Max(serialNumber: String, manufactureDate: Date)
    case river3(serialNumber: String, manufactureDate: Date)
    case river3Pro(serialNumber: String, manufactureDate: Date)
    case river3Max(serialNumber: String, manufactureDate: Date)
    case unknown(serialNumber: String)
    
    var displayName: String {
        switch self {
        case .deltaPro: return "DELTA Pro"
        case .deltaMax: return "DELTA Max"
        case .delta2(_, _, let modelCode):
            if modelCode.contains("30") {
                return "DELTA 2"
            } else {
                return "DELTA 2 (\(modelCode))"
            }
        case .delta2Max: return "DELTA 2 Max"
        case .river2Pro: return "RIVER 2 Pro"
        case .river2Max: return "RIVER 2 Max"
        case .river3: return "RIVER 3"
        case .river3Pro: return "RIVER 3 Pro"
        case .river3Max: return "RIVER 3 Max"
        case .unknown: return "Unknown EcoFlow Product"
        }
    }
    
    var capacity: Int {
        switch self {
        case .deltaPro: return 3600
        case .deltaMax: return 2016
        case .delta2(_, _, let modelCode):
            if modelCode.contains("30") {
                return 1024  // EFD2-1-30 model has 1024Wh
            } else {
                return 1024  // Default to standard capacity if unknown variant
            }
        case .delta2Max: return 2048
        case .river2Pro: return 768
        case .river2Max: return 512
        case .river3: return 600
        case .river3Pro: return 768
        case .river3Max: return 880
        case .unknown: return 0
        }
    }
}

struct EcoFlowParser {
    // Model code to serial number pattern mapping
    private static let modelPatterns: [(pattern: String, modelCode: String)] = [
        // DELTA 2
        ("R331ZAB", "EFD2-1-30"),  // Specific pattern for DELTA 2
        
        // RIVER 3 series
        ("R330[A-Z]{3}", "EFR3-1-30"), // RIVER 3
        ("R331[A-Z]{3}", "EFR3-1-31"), // RIVER 3 Pro (excluding DELTA 2 pattern)
        ("R332[A-Z]{3}", "EFR3-1-32")  // RIVER 3 Max
    ]
    
    static func parse(serialNumber: String) -> EcoFlowProduct {
        let cleaned = serialNumber.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Early return if serial number is too short
        guard cleaned.count >= 7 else {
            return .unknown(serialNumber: serialNumber)
        }
        
        // If it's a model code (e.g., "EFD2-1-30"), parse directly
        if cleaned.hasPrefix("EF") {
            return parseModelCode(cleaned, serialNumber: serialNumber)
        }
        
        // Check for specific DELTA 2 pattern first
        if cleaned.hasPrefix("R331ZAB") {
            return .delta2(serialNumber: serialNumber, manufactureDate: Date(), modelCode: "EFD2-1-30")
        }
        
        // Legacy format fallback
        return parseLegacyFormat(serialNumber: cleaned)
    }
    
    private static func parseModelCode(_ modelCode: String, serialNumber: String) -> EcoFlowProduct {
        if modelCode.contains("EFD2") {
            return .delta2(serialNumber: serialNumber, manufactureDate: Date(), modelCode: modelCode)
        }
        
        switch modelCode {
        case "EFR3-1-30":
            return .river3(serialNumber: serialNumber, manufactureDate: Date())
        case "EFR3-1-31":
            return .river3Pro(serialNumber: serialNumber, manufactureDate: Date())
        case "EFR3-1-32":
            return .river3Max(serialNumber: serialNumber, manufactureDate: Date())
        default:
            return .unknown(serialNumber: serialNumber)
        }
    }
    
    private static func parseLegacyFormat(serialNumber: String) -> EcoFlowProduct {
        // Legacy format code remains the same...
        let productCode = String(serialNumber.prefix(3))
        let yearStr = String(serialNumber[serialNumber.index(serialNumber.startIndex, offsetBy: 3)...serialNumber.index(serialNumber.startIndex, offsetBy: 4)])
        let monthStr = String(serialNumber[serialNumber.index(serialNumber.startIndex, offsetBy: 5)...serialNumber.index(serialNumber.startIndex, offsetBy: 6)])
        
        // Parse date
        guard let year = Int(yearStr),
              let month = Int(monthStr),
              month >= 1 && month <= 12 else {
            return .unknown(serialNumber: serialNumber)
        }
        
        // Create manufacture date
        var dateComponents = DateComponents()
        dateComponents.year = 2000 + year
        dateComponents.month = month
        dateComponents.day = 1
        
        guard let manufactureDate = Calendar.current.date(from: dateComponents) else {
            return .unknown(serialNumber: serialNumber)
        }
        
        // Match product code to product type
        switch productCode {
        case "DPR":
            return .deltaPro(serialNumber: serialNumber, manufactureDate: manufactureDate)
        case "DMX":
            return .deltaMax(serialNumber: serialNumber, manufactureDate: manufactureDate)
        case "D2P":
            return .delta2(serialNumber: serialNumber, manufactureDate: manufactureDate, modelCode: "EFD2-1-30")
        case "D2M":
            return .delta2Max(serialNumber: serialNumber, manufactureDate: manufactureDate)
        case "R2P":
            return .river2Pro(serialNumber: serialNumber, manufactureDate: manufactureDate)
        case "R2M":
            return .river2Max(serialNumber: serialNumber, manufactureDate: manufactureDate)
        default:
            return .unknown(serialNumber: serialNumber)
        }
    }
}

// MARK: - Helper Extensions
extension EcoFlowProduct {
    var manufactureDateString: String {
        switch self {
        case .deltaPro(_, let date),
             .deltaMax(_, let date),
             .delta2(_, let date, _),
             .delta2Max(_, let date),
             .river2Pro(_, let date),
             .river2Max(_, let date),
             .river3(_, let date),
             .river3Pro(_, let date),
             .river3Max(_, let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/yyyy"
            return formatter.string(from: date)
        case .unknown:
            return "Unknown"
        }
    }
    
    var serialNumber: String {
        switch self {
        case .deltaPro(let sn, _),
             .deltaMax(let sn, _),
             .delta2(let sn, _, _),
             .delta2Max(let sn, _),
             .river2Pro(let sn, _),
             .river2Max(let sn, _),
             .river3(let sn, _),
             .river3Pro(let sn, _),
             .river3Max(let sn, _),
             .unknown(let sn):
            return sn
        }
    }
}
