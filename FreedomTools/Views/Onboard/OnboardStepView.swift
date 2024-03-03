import SwiftUI

struct OnboardStepView: View {
    @ObservedObject var onboardController = OnboardController()
    
    var body: some View {
        VStack {
            HStack {
                (Text("Step") + Text(" \(onboardController.currentStep.rawValue)/3"))
                    .font(.custom("RobotoMono-Regular", size: 16))
                    .opacity(0.5)
                Spacer()
                Button(action: onboardController.cancel) {
                    Image("Cancel")
                        .resizable()
                        .frame(width: 15, height: 15)
                }
                .buttonStyle(.plain)
            }
            .padding()
            HStack {
                Text(LocalizedStringKey(onboardController.currentStep.title))
                    .font(.custom("RobotoMono-Bold", size: 20))
                Spacer()
            }
            .padding(.horizontal)
            HStack {
                Text(LocalizedStringKey(onboardController.currentStep.description))
                    .font(.custom("RobotoMono-Regular", size: 14))
                    .opacity(0.5)
                Spacer()
            }
            .frame(height: 10)
            .padding(.horizontal)
        }
    }
}

#Preview {
    OnboardStepView(onboardController: OnboardController())
}
