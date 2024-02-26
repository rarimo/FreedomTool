import SwiftUI
import Identity
import NFCPassportReader

struct AppView: View {
    @StateObject private var appController = AppController()
    @StateObject var introController = IntroController()
    @StateObject var onboardController = OnboardController()
    @StateObject var mainController = MainController()
    
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
                    introController: introController,
                    onboardController: onboardController
                )
            }
            if introController.isOff && !onboardController.isOff {
                OnboardView(onboardController: onboardController)
            }
        }
        .environment(\.locale, .init(identifier: appController.localization))
    }
}

#Preview {
    AppView()
}
