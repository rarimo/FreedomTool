import SwiftUI

struct WaitProcessView: View {
    let waitTitle: String
    let waitDesc: String
    let doneTitle: String
    let doneDesc: String
    
    let waitTill: DispatchTime
    
    let onDone: () -> Void
    
    init(
        waitTitle: String,
        waitDesc: String,
        doneTitle: String,
        doneDesc: String,
        waitTill: DispatchTime = DispatchTime.now() + 2.0,
        onDone: @escaping () -> Void
    ) {
        self.waitTitle = waitTitle
        self.waitDesc = waitDesc
        self.doneTitle = doneTitle
        self.doneDesc = doneDesc
        self.onDone = onDone
        self.waitTill = waitTill
    }
    
    @State private var isDone = false
    
    var body: some View {
        VStack {
            Image(isDone ? "Done" : "Wait")
                .resizable()
                .frame(width: 90, height: 90)
            Text(LocalizedStringKey(isDone ? doneTitle : waitTitle))
                .font(.custom("RobotoMono-Semibold", size: 20))
                .frame(height: 30)
            Text(LocalizedStringKey(isDone ? doneDesc : waitDesc))
                .font(.custom("RobotoMono-Regular", size: 15))
                .multilineTextAlignment(.center)
                .opacity(0.5)
                .frame(width: 250)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: waitTill) {
                isDone = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: waitTill + 1.5) {
                onDone()
            }
        }
    }
}

#Preview {
    WaitProcessView(
        waitTitle: "Please Wait...",
        waitDesc: "Creating anonymized identity proof",
        doneTitle: "All Done!",
        doneDesc: "You will be redirected in few seconds"
    ) {}
}
