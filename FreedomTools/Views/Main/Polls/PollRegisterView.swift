import SwiftUI

struct PollRegisterView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var onboardController: OnboardController
    
    let poll = Poll.sampleData[0]
    
    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            ZStack {
                Image("ArrowLeft")
                    .resizable()
                    .frame(width: 10, height: 15)
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
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
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: btnBack)
        }
    }
}

#Preview {
    PollRegisterView(
        onboardController: OnboardController()
    )
}
