import SwiftUI
import VisionKit

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showScanner = false
    @State private var scannedText: String = ""
    @State private var hasPermission: Bool = false
    
    var onScanCompletion: (String) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                    if hasPermission {
                        LiveTextScannerView(scannedText: $scannedText) { text in
                            onScanCompletion(text)
                            dismiss()
                        }
                    } else {
                        Text("Camera access is required")
                            .foregroundColor(.red)
                    }
                } else {
                    Text("This device doesn't support live text scanning")
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
            .onAppear {
                requestCameraPermission()
            }
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            hasPermission = granted
        }
    }
}

struct LiveTextScannerView: UIViewControllerRepresentable {
    @Binding var scannedText: String
    var onScanCompletion: (String) -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [.text()],
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
            default:
                break
            }
        }
    }
}