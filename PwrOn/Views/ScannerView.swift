import SwiftUI
import VisionKit

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showScanner = false
    @State private var scannedText: String = ""
    
    var onScanCompletion: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                    LiveTextScannerView(scannedText: $scannedText) { text in
                        onScanCompletion(text)
                        dismiss()
                    }
                } else {
                    Text("This device doesn't support scanning")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Scan Serial Number")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LiveTextScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    var onScanCompletion: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [
                .text(),
                .barcode(symbologies: [
                    .upce,
                    .code39,
                    .code39Checksum,
                    .code39FullASCII,
                    .code39FullASCIIChecksum,
                    .code93,
                    .code93i,
                    .code128,
                    .qr,
                    .ean8,
                    .ean13,
                    .pdf417
                ])
            ],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        vc.delegate = context.coordinator
        try? vc.startScanning()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: LiveTextScannerView
        
        init(_ parent: LiveTextScannerView) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                parent.scannedText = text.transcript
                parent.onScanCompletion(text.transcript)
            case .barcode(let barcode):
                if let payload = barcode.payloadStringValue {
                    parent.scannedText = payload
                    parent.onScanCompletion(payload)
                }
            @unknown default:
                break
            }
        }
    }
}
