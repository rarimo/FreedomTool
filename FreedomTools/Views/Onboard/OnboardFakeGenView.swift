import SwiftUI

struct OnboardFakeGenView: View {
    @ObservedObject var onboardController: OnboardController
    
    var body: some View {
        VStack {
            Spacer()
            WaitProcessView(
                waitTitle: "PleaseWait",
                waitDesc: "PleaseWaitSub",
                doneTitle: "AllDone",
                doneDesc: "AllDoneSub",
                waitTill: .now() + 4
            ) {
                onboardController.nextStep()
            }
            
            Spacer()
            VStack {
                Divider()
                (
                    Text("Remember")
                        .font(.custom("RobotoMono-Medium", size: 11)) +
                    Text("RememberHint")
                        .font(.custom("RobotoMono-Regular", size: 11))
                )
                .multilineTextAlignment(.center)
                .opacity(0.5)
                .padding(.top)
            }
                .padding()
        }
    }
}

#Preview {
    OnboardFakeGenView(onboardController: OnboardController())
}
