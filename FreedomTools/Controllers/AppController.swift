import SwiftUI

class AppController: ObservableObject {
    @Published var localization = Locale.current.identifier == "ru_US" ? "ru" : "en"
    
    func switchLocalization() {
        switch self.localization {
        case "ru":
            self.localization = "en"
        case "en":
            self.localization = "ru"
        default:
            self.localization = "ru"
        }
    }
}
