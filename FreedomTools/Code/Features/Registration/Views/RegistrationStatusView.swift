import SwiftUI

struct RegistrationStatusView: View {
    let till: Date
    
    init(registrationEntity: RegistrationEntity) {
        let endTimestamp = registrationEntity.info.values.commitmentEndTime
            
        till = Date(timeIntervalSince1970: TimeInterval(Int(exactly: endTimestamp)!))
    }
    
    var body: some View {
        HStack {
            if Date() < till {
                (Text("EndsIn") + Text(" \(till.timeUntil())"))
                    .font(.custom("Inter-Regular", size: 12))
                    .opacity(0.6)
            } else {
                Text("Ended")
                    .font(.custom("Inter-Regular", size: 12))
                    .opacity(0.6)
            }
        }
    }
}

#Preview {
    RegistrationStatusView(registrationEntity: RegistrationEntity.sample)
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
                return (Text("\(hours) ") + Text(LocalizedStringKey("Hours")))
                    .foregroundColor(.blood)
            } else {
                return Text(LocalizedStringKey("LessThanHour"))
            }
        } else {
            return Text("Invalid date")
        }
    }
}
