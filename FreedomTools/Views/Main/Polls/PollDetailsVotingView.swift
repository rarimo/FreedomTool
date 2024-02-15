import SwiftUI

struct PollDetailsVotingView: View {
    @Binding var isVoting: Bool
    
    let candidates: [String]
    
    @State var chosenCandidat: String? = nil
    
    var body: some View {
        VStack {
            ForEach(candidates, id: \.self) { candidat in
                Button(action: {
                    chosenCandidat = candidat
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(chosenCandidat != candidat ? .black: .second)
                            .opacity(chosenCandidat != candidat ? 0.05 : 1)
                        HStack {
                            Text(candidat)
                                .font(.custom("RobotoMono-Medium", size: 15))
                                .padding(.leading)
                            Spacer()
                        }
                    }
                    .frame(width: 350, height: 50)
                }
                .buttonStyle(.plain)
            }
            Spacer()
            Button(action: {
                isVoting = true
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 350, height: 53)
                        .foregroundStyle(chosenCandidat == nil ? .black: .second)
                        .opacity(chosenCandidat == nil ? 0.1 : 1)
                    Text("Голосовать")
                        .font(.custom("RobotoMono-Bold", size: 15))
                }
            }
            .disabled(chosenCandidat == nil)
            .buttonStyle(.plain)
            Text("Вы не можете изменить свой голос")
                .font(.custom("RobotoMono-Regular", size: 12))
                .padding(.top)
        }
    }
}

#Preview {
    PollDetailsVotingView(isVoting: .constant(false), candidates: [])
}
