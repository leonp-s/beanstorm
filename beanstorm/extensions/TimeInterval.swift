import Foundation

extension TimeInterval {
    var formattedMinsSecs: String {
        let endingDate = Date()
        let startingDate = endingDate.addingTimeInterval(-self)
        let calendar = Calendar.current

        var componentsNow = calendar.dateComponents([.hour, .minute, .second], from: startingDate, to: endingDate)
        if let minute = componentsNow.minute, let seconds = componentsNow.second {
            return "\(String(format: "%02d", minute)):\(String(format: "%02d", seconds))"
        } else {
            return "00:00"
        }
    }
}
