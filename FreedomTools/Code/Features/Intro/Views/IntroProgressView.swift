import SwiftUI

struct IntroProgressView: View {
    @ObservedObject var introController: IntroController
    
    @State private var isOneFinished = false
    @State private var isTwoFinished = false
    @State private var isThreeFinished = false
    
    var body: some View {
        VStack {
            HStack {
                IntroProgressItemView(
                    introController: introController,
                    isActive: introController.isOne,
                    isFinished: $isOneFinished
                )
                IntroProgressItemView(
                    introController: introController,
                    isActive: introController.isTwo,
                    isFinished: $isTwoFinished
                )
                IntroProgressItemView(
                    introController: introController,
                    isActive: introController.isThree,
                    isFinished: $isThreeFinished
                )
            }
        }
        .onChange(of: introController.currentStepIndex) { index in
            if index >= 1 {
                isOneFinished = true
            }
            
            if index >= 2 {
                isTwoFinished = true
            }
            
            if index >= 3 {
                isThreeFinished = true
            }
        }
    }
}

#Preview {
    IntroProgressView(introController: IntroController())
}
