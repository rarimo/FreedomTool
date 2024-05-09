import SwiftUI

struct MainView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @StateObject private var registrationController = RegistrationController()
    
    @State var registrationEntity: RegistrationEntity? = nil
    @State var isStatusActive = true
    @State var isExiting = false
    @State var isSettingsActive = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                HoodView()
                VStack {
                    MainTopView(isSettingsActive: $isSettingsActive)
                        .padding()
                    StatusSelectorView(isActive: $isStatusActive)
                    if isStatusActive {
                        if let registrationEntity = registrationEntity {
                            MainActiveView(
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
                    
                    if let user = appViewModel.user {
                        try? UserStorage.eraceUser(id: user.id)
                    }
                    
                    appViewModel.identityManager = nil
                    appViewModel.user = nil
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
            .sheet(isPresented: $isSettingsActive) {
                SettingsView(isActive: $isSettingsActive, isLoggingOut: $isExiting)
                    .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppView.ViewModel())
}
