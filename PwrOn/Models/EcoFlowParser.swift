import Foundation

enum EcoFlowProduct {
    case deltaPro(serialNumber: String, manufactureDate: Date)
    case deltaMax(serialNumber: String, manufactureDate: Date)
    case delta2(serialNumber: String, manufactureDate: Date)
    case delta2Max(serialNumber: String, manufactureDate: Date)
    case river2Pro(serialNumber: String, manufactureDate: Date)
    case river2Max(serialNumber: String, manufactureDate: Date)
    case unknown(serialNumber: String)
    
    var displayName: String {
        switch self {
        case .deltaPro: return "DELTA Pro"
        case .deltaMax: return "DELTA Max"
        case .delta2: return "DELTA 2"
        case .delta2Max: return "DELTA 2 Max"
        case .river2Pro: return "RIVER 2 Pro"
        case .river2Max: return "RIVER 2 Max"
        case .unknown: return "Unknown EcoFlow Product"
        }
    }
    
    var capacity: Int {
        switch self {
        case .deltaPro: return 3600
        case .deltaMax: return 2016
        case .delta2: return 1024
        case .delta2Max: return 2048
        case .river2Pro: return 768
        case .river2Max: return 512
        case .unknown: return 0
        }
    }
}

struct EcoFlowParser {
    // Example serial number format: D2P + YY + MM + XXXXX
    // D2P: Product code
    // YY: Year (22, 23, etc)
    // MM: Month (01-12)
    // XXXXX: Sequential number
    
    static func parse(serialNumber: String) -> EcoFlowProduct {
        let cleaned = serialNumber.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Early return if serial number is too short
        guard cleaned.count >= 9 else {
            return .unknown(serialNumber: serialNumber)
        }
        
        // Extract components
        let productCode = String(cleaned.prefix(3))
        let yearStr = String(cleaned[cleaned.index(cleaned.startIndex, offsetBy: 3)...cleaned.index(cleaned.startIndex, offsetBy: 4)])
        let monthStr = String(cleaned[cleaned.index(cleaned.startIndex, offsetBy: 5)...cleaned.index(cleaned.startIndex, offsetBy: 6)])
        
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
            return .delta2(serialNumber: serialNumber, manufactureDate: manufactureDate)
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
             .delta2(_, let date),
             .delta2Max(_, let date),
             .river2Pro(_, let date),
             .river2Max(_, let date):
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
             .delta2(let sn, _),
             .delta2Max(let sn, _),
             .river2Pro(let sn, _),
             .river2Max(let sn, _),
             .unknown(let sn):
            return sn
        }
    }
}