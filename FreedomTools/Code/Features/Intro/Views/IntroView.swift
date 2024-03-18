import SwiftUI

struct IntroView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @StateObject private var introController = IntroController()
    
    var body: some View {
        VStack {
            if introController.isZero {
                IntroFirstView() {
                    introController.nextStep()
                }
            } else {
                if introController.currentStepIndex != 4 {
                    IntroProgressView(introController: introController)
                }
                TabView(selection: $introController.currentStepIndex) {
                    IntroStepView(step: .one)
                        .tag(1)
                    IntroStepView(step: .two)
                        .tag(2)
                    IntroStepView(step: .three)
                        .tag(3)
                    ProgressView()
                        .controlSize(.large)
                        .tag(4)
                }
                .onChange(of: introController.currentStepIndex) { index in
                    if index == 4 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            introController.finish()
                            appViewModel.finishIntro()
                        }
                        
                        return
                    }
                    
                    introController.setStep(IntroController.Step(rawValue: introController.currentStepIndex) ?? .off)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                Spacer()
                if introController.currentStepIndex != 4 {
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
    }
}

#Preview {
    IntroView()
        .environmentObject(AppView.ViewModel())
}
