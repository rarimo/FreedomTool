import SwiftUI

struct RegisterNFCScannerView: View {
    @ObservedObject var nfcScannerController: NFCScannerController
    let mrzKey: String
    
    var body: some View {
        VStack {
            HStack {
                Text("ScanNFC")
                    .font(.custom("Inter-Bold", size: 20))
                Spacer()
            }
            .padding(.horizontal)
            HStack {
                Text("ScanNFCSub")
                    .font(.custom("Inter-Regular", size: 14))
                    .opacity(0.5)
                Spacer()
            }
            .frame(height: 10)
            .padding(.horizontal)
            HStack {
                GifImage("merged")
                    .frame(width: 300, height: 300)
            }
            .padding(.bottom)
            VStack {
                HStack {
                    Text("NFCHint1")
                        .font(.custom("Inter-Regular", size: 15))
                        .opacity(0.5)
                    Spacer()
                }
                .padding(.bottom)
                HStack {
                    Text("NFCHint2")
                        .font(.custom("Inter-Regular", size: 15))
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
                        .font(.custom("Inter-Semibold", size: 15))
                }
                .frame(width: 325, height: 55)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    RegisterNFCScannerView(nfcScannerController: NFCScannerController(), mrzKey: "")
}
