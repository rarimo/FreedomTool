import SwiftUI

struct MainView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @StateObject private var registrationController = RegistrationController()
    
    @State var registrationEntity: RegistrationEntity? = nil
    @State var isStatusActive = true
    @State var isExiting = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                HoodView()
                VStack {
                    MainTopView(isExiting: $isExiting)
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
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppView.ViewModel())
}
