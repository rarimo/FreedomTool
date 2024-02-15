import SwiftUI

struct PollDetailsView: View {
    @ObservedObject var onboardController: OnboardController
    @Binding var selectedPollId: UUID?
    
    let poll: Poll
    
    @State var isPending = false
    @State var isVoting = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        selectedPollId = nil
                    }) {
                        ZStack {
                            Circle()
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                            Image("ArrowLeft")
                                .resizable()
                                .frame(width: 10, height: 15)
                        }
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding()
                PollDetailsHeaderView(poll: poll)
                PollDetailsPandingView(onboardController: onboardController, poll: poll)
                if onboardController.isZero {
                    Button(action: {
                        onboardController.nextStep()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundStyle(.black)
                            HStack {
                                Image("Participate")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Authorize")
                                    .font(.custom("RobotoMono-Semibold", size: 15))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 325, height: 55)
                    }
                    .buttonStyle(.plain)
                }
            }
            if isPending || isVoting {
                ZStack {
                    Color.white
                    if isPending {
                        PollPendingView(selectedPollId: $selectedPollId)
                    }
                    if isVoting {
                        PollVotingView(selectedPollId: $selectedPollId)
                    }
                }
            }
        }
    }
}

#Preview {
    PollDetailsView(
        onboardController: OnboardController(),
        selectedPollId: .constant(nil),
        poll: Poll.sampleData[0]
    )
}
