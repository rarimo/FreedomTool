import SwiftUI

struct PollDetailsEndedView: View {
    let winners: [(candidat: String, persent: Int)]
    
    @State var biggestWinner: (String, Int)? = nil
    
    var body: some View {
        ForEach(winners, id: \.candidat) { winner in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.borderGray)
                    .foregroundStyle(.white)
                VStack {
                    Spacer()
                    ProgressView(value: Float(winner.persent), total: 100)
                        .tint(biggestWinner?.0 ?? "" == winner.candidat ? .second : .gray)
                }
                .frame(width: 340)
                HStack {
                    Text(winner.candidat)
                        .font(.custom("RobotoMono-Medium", size: 15))
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .opacity(biggestWinner?.0 ?? "" == winner.candidat ? 1 : 0.1)
                            .foregroundStyle(biggestWinner?.0 ?? "" == winner.candidat ? .second : .black)
                        Text("\(winner.persent)%")
                            .font(.custom("RobotoMono-Medium", size: 15))
                    }
                    .frame(width: 50, height: 25)
                }
                .padding()
            }
            .frame(width: 350, height: 50)
            .onAppear {
                if biggestWinner?.1 ?? 0 < winner.persent {
                    biggestWinner = (winner.candidat, winner.persent)
                }
            }
        }
        .padding(.top)
        Spacer()
    }
}

#Preview {
    PollDetailsEndedView(winners: [])
}
