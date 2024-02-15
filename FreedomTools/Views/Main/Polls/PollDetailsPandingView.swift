import SwiftUI

struct PollDetailsPandingView: View {
    @ObservedObject var onboardController: OnboardController
    let poll: Poll
    
    var body: some View {
        HStack {
            Text("VotingCriteria")
                .font(.custom("RobotoMono-Bold", size: 17))
                .opacity(0.5)
                .padding()
            Spacer()
        }
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .opacity(0.05)
            HStack {
                Text("Status")
                    .font(.custom("RobotoMono-Regular", size: 16))
                    .padding(.horizontal)
                Spacer()
                if onboardController.isZero {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.betterYellow)
                        HStack {
                            Text("VerificationRequired")
                                .font(.custom("RobotoMono-Medium", size: 14))
                                .foregroundStyle(.black)
                        }
                    }
                    .frame(width: 200, height: 30)
                    .padding(.horizontal)
                }
                if onboardController.isOff {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.second)
                        HStack {
                            Image("Check")
                                .resizable()
                                .renderingMode(.original)
                                .foregroundStyle(.black)
                                .frame(width: 13, height: 13)
                            Text("Suitable")
                                .font(.custom("RobotoMono-Medium", size: 14))
                                .foregroundStyle(.black)
                        }
                    }
                    .frame(width: 150, height: 30)
                    .padding(.horizontal)
                }
            }
        }
        .frame(width: 350, height: 50)
        Spacer()
    }
}

#Preview {
    PollDetailsPandingView(onboardController: OnboardController(), poll: Poll.sampleData[0])
}
