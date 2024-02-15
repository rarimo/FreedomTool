import SwiftUI

struct PollStatusView: View {
    let poll: Poll
    
    var body: some View {
        HStack {
            if case .pending(let till, _) = poll.status {
            (Text("StartsIn") + Text(" \(till.timeUntil())"))
                    .font(.custom("RobotoMono-Regular", size: 14))
                    .opacity(0.6)
            }
            if case .voting(let till, _) = poll.status {
                Text("Заканчивается через \(till.timeUntil())")
                    .font(.custom("RobotoMono-Regular", size: 14))
                    .opacity(0.6)
            }
            if case .ended(let at, _) = poll.status {
                Text("Закончилось в \(at.formatted())")
                    .font(.custom("RobotoMono-Regular", size: 14))
                    .opacity(0.6)
            }
        }
    }
}

#Preview {
    PollStatusView(poll: Poll.sampleData[0])
}

extension Date {
    func timeUntil() -> String {
        let currentDate = Date()
        let calendar = Calendar.current

        let components = calendar.dateComponents([.day, .hour], from: currentDate, to: self)

        if let days = components.day, let hours = components.hour {
            if days > 0 && hours > 0 {
                return "\(days) days, \(hours) hours"
            } else if days > 0 {
                return "\(days) days"
            } else if hours > 0 {
                return "\(hours) hours"
            } else {
                return "Less than an hour"
            }
        } else {
            return "Invalid date"
        }
    }
}
