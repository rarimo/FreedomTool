import SwiftUI

struct IntroFirstView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    let onStart: () -> Void
    
    init(onStart: @escaping () -> Void) {
        self.onStart = onStart
    }
    
    var body: some View {
        VStack() {
            HStack {
                Text("Freedom Tool")
                    .font(.custom("Inter-Regular", size: 20))
                    .bold()
                Spacer()
                LocalizationSwitcherView()
            }
            .padding(.horizontal)
            .padding(.leading)
            .padding(.top)
            .padding(.top)
            HStack {
                Text("IntroZeroDescription")
                    .font(.custom("Inter-Regular", size: 14))
                    .opacity(0.5)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.leading)
            Image("IntroPeople")
                .resizable()
                .frame(width: 390, height: 390)
            Spacer()
            Button(action: onStart) {
                ZStack {
                    RoundedRectangle(cornerRadius: 1000)
                        .foregroundStyle(.second)
                    Text("Start")
                        .font(.custom("Inter-Bold", size: 14))
                }
            }
            .buttonStyle(.plain)
            .frame(width: 326, height: 50)
            HStack {
                Image("ShieldLocked")
                    .resizable()
                    .frame(width: 15, height: 15)
                Text("SafeAndDecentralized")
                    .font(.custom("Inter-Regular", size: 13))
                    .opacity(0.5)
            }
            .frame(height: 30)
        }
    }
}

#Preview {
    IntroFirstView() {}
        .environmentObject(AppView.ViewModel())
}
