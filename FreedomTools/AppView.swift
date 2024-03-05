import Web3
import SwiftUI
import Identity
import KeychainAccess
import NFCPassportReader

struct AppView: View {
    @StateObject private var appController = AppController()
    @StateObject var introController = IntroController()
    @StateObject var mainController = MainController()
    @StateObject private var registrationController: RegistrationController = RegistrationController()
    
    var body: some View {
        ZStack {
            if !introController.isOff {
                IntroView(
                    appController: appController,
                    introController: introController
                )
            }
            if introController.isOff {
                MainView(
                    appController: appController,
                    mainController: mainController,
                    introController: introController
                )
            }
        }
        .environment(\.locale, .init(identifier: appController.localization))
    }
}

#Preview {
    AppView()
}
