import SwiftUI

struct PollDetailsHeaderView: View {    
    let poll: Poll
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(poll.title))
                .font(.custom("RobotoMono-Bold", size: 20))
                .padding()
            Spacer()
        }
        HStack {
            Text(LocalizedStringKey(poll.desc))
                .font(.custom("RobotoMono-Regular", size: 15))
                .padding(.horizontal)
                .opacity(0.6)
            Spacer()
        }
        HStack {
            Image("Calendar")
                .resizable()
                .frame(width: 15, height: 15)
                .padding(.leading)
            PollStatusView(poll: poll)
            Spacer()
        }
    }
}

#Preview {
    PollDetailsHeaderView(poll: Poll.sampleData[0])
}
