import SwiftUI

struct EmptyPollsView: View {
    var body: some View {
        Text("EmptyList")
            .font(.custom("RobotoMono-Bold", size: 20))
            .opacity(0.5)
    }
}

#Preview {
    EmptyPollsView()
}