import SwiftUI

struct OnboardView: View {
    @ObservedObject var onboardController: OnboardController
    
    var body: some View {
        ZStack {
            if !onboardController.isZero {
                Color.white
                    .ignoresSafeArea()
            }
            VStack {
                if onboardController.isZero {
                    ZStack {}
                }
                if !onboardController.isZero {
                    OnboardStepView(onboardController: onboardController)
                        .padding(.bottom)
                }
                if onboardController.isOne {
                    OnboardMRZScannerView(mrzScannerController: onboardController.mrzScannerController)
                }
                if onboardController.isTwo {
                    OnboardNFCScannerView(
                        nfcScannerController: onboardController.nfcScannerController,
                        mrzKey: onboardController.mrzScannerController.mrzKey
                    )
                }
//                if onboardController.isThree {
//                    OnboardConfirmDataView(
//                        onboardController: onboardController,
//                        passportModel: onboardController.nfcScannerController.nfcModel!
//                    )
//                }
                if onboardController.isOne {
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
            }
        }
    }
}

#Preview {
    let _onboardController = OnboardController()
    
    _onboardController.nextStep()
    
    return OnboardView(onboardController: _onboardController)
}
