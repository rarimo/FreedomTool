import SwiftUI
import QKMRZScanner

class MRZScannerController: ObservableObject, QKMRZScannerViewDelegate {
    @Published var isScanning = false
    var scanResults: QKMRZScanner.QKMRZScanResult? = nil
    
    var onScanned: () -> Void = {}
    var mrzKey = ""
    
    func mrzScannerView(_ mrzScannerView: QKMRZScanner.QKMRZScannerView, didFind scanResult: QKMRZScanner.QKMRZScanResult) {
        let passwordNumber = scanResult.documentNumber
        let dateOfBirth = scanResult.birthdate ?? Date(timeIntervalSince1970: 0)
        let dateOfExpiry = scanResult.expiryDate ?? Date(timeIntervalSince1970: 0)
        
        
        let mrzDateFormatter = DateFormatter()
        mrzDateFormatter.dateFormat = "YYMMdd"
        
        mrzKey = PassportUtils.getMRZKey(
            passportNumber: passwordNumber,
            dateOfBirth: mrzDateFormatter.string(from: dateOfBirth),
            dateOfExpiry: mrzDateFormatter.string(from: dateOfExpiry)
        )
        
        scanResults = scanResult
        
        stopScanning()
        onScanned()
        
        KeychainUtils.saveBirthday(scanResult.birthdate!)
    }
    
    func setOnScanned(newOnScanned: @escaping () -> Void) {
        onScanned = newOnScanned
    }
    
    
    func startScanning() {
        isScanning = true
    }
    
    func stopScanning() {
        isScanning = false
    }
}

