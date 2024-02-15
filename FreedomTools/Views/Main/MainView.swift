import SwiftUI

struct MainView: View {
    @ObservedObject var appController: AppController
    @ObservedObject var mainController: MainController
    @ObservedObject var introController: IntroController
    @ObservedObject var onboardController: OnboardController
    
    let nationality = KeychainUtils.getNationality()
    let birthday = KeychainUtils.getBirthday()
    
    @State var selectedPollId: UUID? = nil
    @State var isStatusActive = true
    
    @State var isExiting = false
    
    var body: some View {
        ZStack {
            VStack {
                Image("Hood")
                    .ignoresSafeArea()
                    .frame(width: 0, height: 0)
                Spacer()
            }
            VStack {
                HStack {
                    Text("Polls")
                        .font(.custom("RobotoMono-Bold", size: 25))
                        .padding(.leading)
                    Spacer()
                    LocalizationSwitcherView(appController: appController)
                    if onboardController.isOff {
                        Button(action: {
                            isExiting = true
                        }) {
                            ZStack {
                                Circle()
                                    .foregroundStyle(.second)
                                Image("Exit")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .frame(width: 50, height: 50)
                        .offset(x: 10)
                    }
                }
                .padding()
                PollStatusSelectorView(isActive: $isStatusActive)
                if isStatusActive {
                    List(
                        mainController.polls
                            .filter {
                                isStatusActive ? !$0.isEnded : $0.isEnded
                            }
                    ) { poll in
                        Button(action: {
                            selectedPollId = poll.id
                        }) {
                            PollListElemView(poll: poll)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .buttonStyle(.plain)
                    }
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .listStyle(.plain)
                }
                if !isStatusActive {
                    Spacer()
                    EmptyPollsView()
                    Spacer()
                }
                Spacer()
//                TestView(nfcScannerController: onboardController.nfcScannerController)
            }
            if selectedPollId != nil {
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                    PollDetailsView(
                        onboardController: onboardController,
                        selectedPollId: $selectedPollId,
                        poll: mainController.polls.first {
                            $0.id == selectedPollId!
                        }!
                    )
                }
            }
        }
        .confirmationDialog("", isPresented: $isExiting) {
            Button("Yes") {
                KeychainUtils.eraceData()
                onboardController.cancel()
                introController.setStep(.off)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("EraceConfirmation")
        }
    }
}

#Preview {
    MainView(
        appController: AppController(),
        mainController: MainController(),
        introController: IntroController(),
        onboardController: OnboardController()
    )
}
