import Web3
import SwiftUI
import Identity
import KeychainAccess
import NFCPassportReader

struct AppView: View {    
    @StateObject private var appController = AppController()
    @StateObject private var introController = IntroController()
    @StateObject private var mainController = MainController()
    @StateObject private var registrationController = RegistrationController()
    
    var body: some View {
        ZStack {
            if introController.isOff {
                MainView(
                    appController: appController,
                    mainController: mainController,
                    introController: introController
                )
            } else {
                IntroView(
                    appController: appController,
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
