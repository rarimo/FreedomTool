import SwiftUI

struct MainView: View {
    @ObservedObject var appController: AppController
    @ObservedObject var mainController: MainController
    @ObservedObject var introController: IntroController
    @State private var registrationController: RegistrationController = RegistrationController()
    
    @State var registrationEntity: RegistrationEntity? = nil
    @State var isStatusActive = true
    @State var isExiting = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                HoodView()
                VStack {
                    MainTopView(appController: appController, isExiting: $isExiting)
                        .padding()
                    PollStatusSelectorView(isActive: $isStatusActive)
                    if isStatusActive {
                        if let registrationEntity = registrationEntity {
                            MainActiveView(
                                appController: appController,
                                registrationEntity: registrationEntity
                            )
                        } else {
                            Spacer()
                            ProgressView()
                                .controlSize(.large)
                        }
                    } else {
                        Spacer()
                        EmptyPollsView()
                        Spacer()
                    }
                    Spacer()
                }
            }
            .confirmationDialog("", isPresented: $isExiting) {
                Button("Yes") {
                    UserStorage.eraceActiveUserId()
                    
                    appController.identityManager = nil
                    appController.user = nil
                    
                    introController.setStep(.off)
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("EraceConfirmation")
            }
            .onAppear {
                Task {
                    let entity = try? await RegistrationEntity.fromRegistryLast()
                    
                    DispatchQueue.main.async {
                        self.registrationEntity = entity
                    }
                }
            }
        }
    }
}

#Preview {
    MainView(
        appController: AppController(),
        mainController: MainController(),
        introController: IntroController()
    )
}
