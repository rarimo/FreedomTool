import SwiftUI

struct PollListElemView: View {
    let poll: Poll
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.white)
                .shadow(radius: 1, x: 0, y: 1)
            VStack {
                HStack {
                    Text(LocalizedStringKey(poll.title))
                        .font(.custom("RobotoMono-Medium", size: 15))
                    Spacer()
                }
                .padding(.leading)
                .frame(height: 60)
                HStack {
                    Text(LocalizedStringKey(poll.desc))
                        .font(.custom("RobotoMono-Regular", size: 12))
                    Spacer()
                }
                .padding(.leading)
                Spacer()
                Divider()
                    .frame(width: 340)
                HStack {
                    Image("Calendar")
                        .resizable()
                        .frame(width: 20, height: 20)
                    PollStatusView(poll: poll)
                    Spacer()
                    Image("RightArrow")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .padding(.bottom)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    PollListElemView(poll: Poll.sampleData[0])
}
