import SwiftUI

struct OnboardMRZScannerView: View {
    @ObservedObject var mrzScannerController: MRZScannerController
    
    var body: some View {
        VStack {
            ZStack {
                MRZScannerView(mrtScannerController: mrzScannerController)
                    .mask {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 380, height: 300)
                    }
                Image("PassportTemplate")
                    .resizable()
                    .frame(width: 380, height: 300)
            }
            .frame(height: 400)
            Text("MRZHint")
                .font(.custom("RobotoMono-Regular", size: 15))
                .multilineTextAlignment(.center)
                .frame(width: 300)
                .opacity(0.5)
        }
        .onAppear {
            mrzScannerController.startScanning()
        }
    }
}

extension String {
    func parsableDateToPretty() -> String {
        let partYearStartIndex = self.startIndex
        let partYearEndIndex = self.index(self.startIndex, offsetBy: 2)
        
        let partYear = self[partYearStartIndex..<partYearEndIndex]
        
        let year = Int(partYear, radix: 10)! <= 34 ? "20" + partYear : "19" + partYear
        
        let monthStartIndex = self.index(self.startIndex, offsetBy: 2)
        let monthEndIndex = self.index(self.startIndex, offsetBy: 4)
        
        let month = self[monthStartIndex..<monthEndIndex]
        
        let dayStartIndex = self.index(self.startIndex, offsetBy: 4)
        let dayEndIndex = self.index(self.startIndex, offsetBy: 6)
        
        let day = self[dayStartIndex..<dayEndIndex]
        
        return "\(year).\(month).\(day)"
    }
}

#Preview {
    OnboardMRZScannerView(mrzScannerController: MRZScannerController())
}
