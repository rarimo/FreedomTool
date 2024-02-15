import SwiftUI

struct PollStatusSelectorView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .opacity(0.05)
            HStack(spacing: 4) {
                Button(action: {
                    isActive = true
                }) {
                    ZStack {
                        if isActive {
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundStyle(.white)
                                .shadow(radius: 1, x: 0, y: 1)
                        }
                        Text("Active")
                            .font(.custom("RobotoMono-Medium", size: 14))
                            .opacity(isActive ? 1 : 0.5)
                    }
                    .frame(width: 170, height: 30)
                }
                .buttonStyle(.plain)
                Button(action: {
                    isActive = false
                }) {
                    ZStack {
                        if !isActive {
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundStyle(.white)
                                .shadow(radius: 1, x: 0, y: 1)
                        }
                        Text("Finished")
                            .font(.custom("RobotoMono-Medium", size: 14))
                            .opacity(!isActive ? 1 : 0.5)
                    }
                    .frame(width: 170, height: 30)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 350, height: 35)
    }
}

#Preview {
    PollStatusSelectorView(isActive: .constant(true))
}
