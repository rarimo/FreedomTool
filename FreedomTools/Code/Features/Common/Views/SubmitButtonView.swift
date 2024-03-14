import SwiftUI

struct SubmitButtonView: View {
    let text: String
    let action: () -> Void
    
    @State var isDisabled = false
    
    init(_ text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            isDisabled = true
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundStyle(.second)
                Text(LocalizedStringKey(text))
                    .font(.custom("RobotoMono-Semibold", size: 15))
            }
            .frame(width: 325, height: 55)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .onChange(of: isDisabled) { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.isDisabled = false
            }
        }
    }
}

#Preview {
    SubmitButtonView("Let's begin") {}
}
