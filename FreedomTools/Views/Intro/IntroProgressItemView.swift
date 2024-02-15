import SwiftUI

struct IntroProgressItemView: View {
    @ObservedObject var introController: IntroController
    
    var isActive: Bool
    @Binding var isFinished: Bool
    
    @State private var progressWidth = 0.0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .opacity(isFinished || isActive ? 1 : 0)
                .frame(width: progressWidth, height: 1)
            Rectangle()
                .opacity(0.1)
                .frame(width: 100, height: 1)
        }
        .onReceive(timer) { time in            
            if isActive && isFinished {
                isFinished = false
                
                progressWidth = 0
            }
            
            
            if isFinished {
                if progressWidth != 100 {
                    progressWidth = 100
                }
                
                return
            }
            
            if isActive {
                progressWidth += 1
                
                if progressWidth >= 100 {
                    introController.nextStep()
                    
                    isFinished = true
                }
                
                return
            }
            
            if progressWidth != 0 {
                progressWidth = 0
                return
            }
        }
    }
}

#Preview {
    IntroProgressItemView(
        introController: IntroController(),
        isActive: true,
        isFinished: .constant(false)
    )
}
