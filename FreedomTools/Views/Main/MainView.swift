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
        NavigationStack {
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
                        List {
                            ZStack {
                                PollListElemView(poll: Poll.sampleData[0])
                                NavigationLink {
                                    PollRegisterView(
                                        onboardController: onboardController
                                    )
                                } label: {
                                    EmptyView()
                                }.opacity(0.0)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .buttonStyle(.plain)
                            .frame(width: 350, height: 190)
                            
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
#if DEBUG
                    TestView(nfcScannerController: onboardController.nfcScannerController)
#endif
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
}

#Preview {
    MainView(
        appController: AppController(),
        mainController: MainController(),
        introController: IntroController(),
        onboardController: OnboardController()
    )
}
