import SwiftUI

struct LocalizationSwitcherView: View {
    @ObservedObject var appController: AppController
    
    var body: some View {
        Button(action: {
            self.appController.switchLocalization()
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
    LocalizationSwitcherView(appController: AppController())
}
