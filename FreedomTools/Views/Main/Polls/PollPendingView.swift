import SwiftUI

struct PollPendingView: View {
    @Binding var selectedPollId: UUID?
    
    var body: some View {
        VStack {
            Spacer()
            WaitProcessView(
                waitTitle: "Пожалуйста, подождите",
                waitDesc: "Ваш запрос не отслеживается",
                doneTitle: "Ваш запрос был отправлен",
                doneDesc: "Пожалуйста, дождитесь начала голосования, чтобы проголосовать",
                waitTill: .now() + 4
            ) {
                selectedPollId = nil
            }
            Divider()
                .frame(width: 350, height: 50)
            PollProcessPendingView()
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
    PollPendingView(selectedPollId: .constant(nil))
}
