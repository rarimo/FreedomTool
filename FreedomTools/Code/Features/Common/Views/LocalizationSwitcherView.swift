import SwiftUI

struct LocalizationSwitcherView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    var body: some View {
        Button(action: {
            self.appViewModel.switchLocalization()
        }) {
            ZStack {
                HStack {
                    Image(systemName: "globe")
                    Text("Country")
                        .font(.custom("RobotoMono-Regular", size: 16))
                }
            }
        }
        .frame(width: 65, height: 35)
        .buttonStyle(.plain)
    }
}

#Preview {
    LocalizationSwitcherView()
        .environmentObject(AppView.ViewModel())
}
