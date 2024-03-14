import SwiftUI
import QKMRZScanner

struct MRZScannerView: UIViewRepresentable {
    @ObservedObject var mrtScannerController: MRZScannerController
    
    init(mrtScannerController: MRZScannerController) {
        self.mrtScannerController = mrtScannerController
    }
    
    typealias UIViewType = QKMRZScannerView
    
    func makeUIView(context: Context) -> QKMRZScanner.QKMRZScannerView {
        QKMRZScannerView()
    }
    
    func updateUIView(_ uiView: QKMRZScanner.QKMRZScannerView, context: Context) {
        if mrtScannerController.isScanning {
            uiView.delegate = mrtScannerController
            uiView.startScanning()
            return
        }
        
        uiView.stopScanning()
    }
    
}
#Preview {
    MRZScannerView(mrtScannerController: MRZScannerController())
}
