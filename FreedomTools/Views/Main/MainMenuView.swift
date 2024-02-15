import SwiftUI

struct MainMenuView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 45)
            HStack {
                ZStack {
                    Circle()
                        .foregroundStyle(.second)
                    Image("Home")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .frame(width: 50, height: 50)
                ZStack {
                    Image("Qr")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .frame(width: 50, height: 50)
            }
            .frame(width: 120)
        }
        .frame(width: 120, height: 60)
        
    }
}

#Preview {
    MainMenuView()
}
