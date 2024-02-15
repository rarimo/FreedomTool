import SwiftUI

struct PollVotingView: View {
    @Binding var selectedPollId: UUID?
    
    var body: some View {
        VStack {
            Spacer()
            WaitProcessView(
                waitTitle: "Пожалуйста, подождите",
                waitDesc: "Ваш голос не отслеживается",
                doneTitle: "Ваш голос отправлен",
                doneDesc: "Пожалуйста, дождитесь окончания голосования, чтобы увидеть результаты",
                waitTill: .now() + 4
            ) {
                selectedPollId = nil
            }
            Divider()
                .frame(width: 350, height: 50)
            PollProcessVotingView()
                .frame(height: 175)
            Spacer()
            VStack {
                Divider()
                (
                    Text("Помните: ")
                        .font(.custom("RobotoMono-Medium", size: 11)) +
                    Text("Ваши данные хранятся только на этом устройстве и никогда не передаются третьим лицам.")
                        .font(.custom("RobotoMono-Regular", size: 11))
                )
                .multilineTextAlignment(.center)
                .opacity(0.5)
                .padding(.top)
            }
                .padding()
        }
    }
}

#Preview {
    PollVotingView(selectedPollId: .constant(nil))
}
