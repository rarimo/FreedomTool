import SwiftUI

struct OnboardParticipateView: View {
    @ObservedObject var onboardController: OnboardController
    
    static let cons = [
        "Hint1",
        "Hint2",
        "Hint3",
        "Hint4"
    ]
    
    var body: some View {
        VStack {
            Spacer()
            Image("Passport")
                .resizable()
                .frame(width: 130, height: 170)
            Text("Participate")
                .font(.custom("RobotoMono-Semibold", size: 20))
                .frame(height: 40)
            Text("ParticipateSub")
                .font(.custom("RobotoMono-Regular", size: 15))
                .opacity(0.5)
                .multilineTextAlignment(.center)
                .frame(width: 300)
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .opacity(0.03)
                VStack {
                    ForEach(OnboardParticipateView.cons, id: \.self) { con in
                        HStack {
                            Image("Check")
                                .resizable()
                                .frame(width: 15, height: 15)
                            Text(con)
                                .font(.custom("RobotoMono-Regular", size: 15))
                                .opacity(0.5)
                            Spacer()
                        }
                        .frame(height: 27)
                    }
                }
                .padding(.leading)
            }
            .frame(width: 350, height: 170)
            .padding(.top)
            Spacer()
            SubmitButtonView("Next") {
                onboardController.nextStep()
            }
            HStack {
                Image("ShieldLocked")
                    .resizable()
                    .frame(width: 15, height: 15)
                Text("SafeAndDecentralized")
                    .font(.custom("RobotoMono-Regular", size: 13))
                    .opacity(0.5)
            }
            .frame(height: 30)
        }
    }
}

#Preview {
    OnboardParticipateView(onboardController: OnboardController())
}
