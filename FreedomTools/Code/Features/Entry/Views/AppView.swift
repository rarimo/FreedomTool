import SwiftUI

struct AppView: View {    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.isDepraceted {
                VersionUpdateView()
            } else {
                if viewModel.isIntroFinished {
                    if viewModel.isLocked {
                        LockView()
                    } else {
                        MainView()
                    }
                } else {
                    IntroView()
                }
            }
        }
        .environmentObject(viewModel)
        .environment(\.locale, .init(identifier: viewModel.localization))
        .onAppear {
            Task { @MainActor in
                do {
                    self.viewModel.isDepraceted = try await viewModel.isUpdateAvailable()
                } catch let error {
                    print("failed to get appstore version: \(error)")
                }
            }
        }
    }
}

#Preview {
    AppView()
}
