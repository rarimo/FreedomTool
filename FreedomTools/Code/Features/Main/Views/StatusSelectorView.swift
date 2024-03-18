import SwiftUI

struct StatusSelectorView: View {
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
                        RoundedRectangle(cornerRadius: 30)
                            .shadow(radius: 1, x: 0, y: 1)
                            .foregroundStyle(isActive ? .white : .clear)
                        Text("Active")
                            .font(.custom("Inter-Medium", size: 14))
                            .opacity(isActive ? 1 : 0.5)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 170, height: 30)
                Button(action: {
                    isActive = false
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 30)
                            .shadow(radius: 1, x: 0, y: 1)
                            .foregroundStyle(!isActive ? .white : .clear)
                        Text("Finished")
                            .font(.custom("Inter-Medium", size: 14))
                            .opacity(!isActive ? 1 : 0.5)
                    }
                    
                }
                .buttonStyle(.plain)
                .frame(width: 170, height: 30)
            }
        }
        .frame(width: 350, height: 35)
    }
}

#Preview {
    StatusSelectorView(isActive: .constant(true))
}
