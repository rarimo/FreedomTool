import SwiftUI

struct OnboardNFCScannerView: View {
    @ObservedObject var nfcScannerController: NFCScannerController
    let mrzKey: String
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                GifImage("merged")
                    .frame(width: 300, height: 300)
            }
            .padding(.bottom)
            VStack {
                HStack {
                    Text("NFCHint1")
                        .font(.custom("RobotoMono-Regular", size: 15))
                        .opacity(0.5)
                    Spacer()
                }
                .padding(.bottom)
                HStack {
                    Text("NFCHint2")
                        .font(.custom("RobotoMono-Regular", size: 15))
                        .opacity(0.5)
                        
                    Spacer()
                }
                .padding(.bottom)
            }
            .frame(width: 335)
            .multilineTextAlignment(.leading)
            Spacer()
            Button(action: {
                nfcScannerController.read(mrzKey)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.second)
                    Text("Scan")
                        .font(.custom("RobotoMono-Semibold", size: 15))
                }
                .frame(width: 325, height: 55)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    OnboardNFCScannerView(nfcScannerController: NFCScannerController(), mrzKey: "")
}
