import SwiftUI

struct RegisterMRZScannerView: View {
    @ObservedObject var mrzScannerController: MRZScannerController
    
    var body: some View {
        VStack {
            HStack {
                Text("ScanDoc")
                    .font(.custom("Inter-Bold", size: 20))
                Spacer()
            }
            .padding(.horizontal)
            HStack {
                Text("ScanDocSub")
                    .font(.custom("Inter-Regular", size: 14))
                    .opacity(0.5)
                Spacer()
            }
            .frame(height: 10)
            .padding(.horizontal)
            Spacer()
            ZStack {
                MRZScannerView(mrtScannerController: mrzScannerController)
                    .mask {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 370, height: 270)
                    }
                LottieView(animationFileName: "passport", loopMode: .loop)
                    .frame(width: 360, height: 230)
            }
            .frame(height: 320)
            Text("MRZHint")
                .font(.custom("Inter-Regular", size: 15))
                .multilineTextAlignment(.center)
                .frame(width: 300)
                .opacity(0.5)
            Spacer()
            Link(destination: URL(string: "https://freedomtool.org/privacy-policy.html")!) {
                HStack {
                    Image("ShieldLocked")
                        .resizable()
                        .frame(width: 15, height: 15)
                    Text("PrivacyPolicy")
                        .underline()
                        .font(.system(size: 13))
                }
            }
                .underline()
                .foregroundStyle(.black)
                .opacity(0.5)
        }
        .onAppear {
            mrzScannerController.startScanning()
        }
    }
}

#Preview {
    RegisterMRZScannerView(mrzScannerController: MRZScannerController())
}
