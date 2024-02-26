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
        }
    }
}

#Preview {
    PollStatusView(poll: Poll.sampleData[0])
}

extension Date {
    func timeUntil() -> Text {
        let currentDate = Date()
        let calendar = Calendar.current

        let components = calendar.dateComponents([.day, .hour], from: currentDate, to: self)

        if let days = components.day, let hours = components.hour {
            if days > 0 && hours > 0 {
                return Text("\(days) ") + Text(LocalizedStringKey("Days")) + Text(", \(hours) ") + Text(LocalizedStringKey("Hours"))
            } else if days > 0 {
                return Text("\(days) ") + Text(LocalizedStringKey("Days"))
            } else if hours > 0 {
                return Text("\(hours) ") + Text(LocalizedStringKey("Hours"))
            } else {
                return Text(LocalizedStringKey("LessThanHour"))
            }
        } else {
            return Text("Invalid date")
        }
    }
}
