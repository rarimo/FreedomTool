import SwiftUI

struct AppView: View {    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
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
        .environmentObject(viewModel)
        .environment(\.locale, .init(identifier: viewModel.localization))
        .onAppear {
            Task { clearUserStorageOnFirstLaunch() }
        }
    }
    
    func clearUserStorageOnFirstLaunch() {
        if StorageUtils.getIsFirstLaunch() {
            try? UserStorage.eraceAll()
            StorageUtils.setIsFirstLaunch(false)
        }
    }
}

#Preview {
    AppView()
}
