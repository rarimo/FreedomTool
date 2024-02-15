import Foundation
import NFCPassportReader

struct Poll: Identifiable {
    let id = UUID()
    
    let title: String
    let desc: String
    let status: Status
    
    enum Status {
        case pending(till: Date, criterias: [String])
        case voting(till: Date, candidates: [String])
        case ended(at: Date, winners: [(candidat: String, persent: Int)])
    }
    
    var isPending: Bool {
        if case .pending(_, _) = status {
            return true
        }
        
        return false
    }
    
    var isVoting: Bool {
        if case .voting(_, _) = status {
            return true
        }
        
        return false
    }
    
    var isEnded: Bool {
        if case .ended(_, _) = status {
            return true
        }
        
        return false
    }
    
    static let sampleData: [Self] = [
//        Self(
//            title: "2024 Парламентские выборы в Джорджия",
//            desc: "Парламентские выборы в Джорджия 2024 года станут 45-ми парламентскими выборами.",
//            status: .pending(
//                till: Date(timeIntervalSinceNow: 60*60*20),
//                criterias: [
//                    "Являетесь гражданином США"
//                ]
//            )
//        ),
//        Self(
//            title: "Президентские выборы в США 2024",
//            desc: "Президентские выборы в США 2024 года станут 60-ми президентскими выборами, проводимыми раз в четыре года.",
//            status: .voting(
//                till: Date(timeIntervalSinceNow: 60*60*24*25),
//                candidates: [
//                    "Joe Biden",
//                    "Donald Trump",
//                    "Robert F. Kennedy"
//                ]
//            )
//        ),
//        Self(
//            title: "Выборы президента России 2024",
//            desc: "Выборы президента России 2024 года станут восьмыми президентскими выборами.",
//            status: .pending(
//                till: Date(timeIntervalSince1970: 1710453600),
//                criterias: [
//                    "Являетесь гражданином России",
//                    "Вам исполнилось 18 лет в день выборов или до него"
//                ]
//            )
//        ),
        Self(
            title: "Poll1",
            desc: "Poll1Desc",
            status: .pending(
                till: Date(timeIntervalSinceNow: 36000),
                criterias: []
            )
        ),
        Self(
            title: "Poll2",
            desc: "Poll2Desc",
            status: .pending(
                till: Date(timeIntervalSinceNow: 2160000),
                criterias: []
            )
        ),
//        Self(
//            title: "Президентские выборы в США 2020",
//            desc: "Президентские выборы в США 2020 года станут 59-ми президентскими выборами, проводимыми раз в четыре года",
//            status: .ended(
//                at: Date(timeIntervalSince1970: 1580860800),
//                winners: [
//                    (
//                        candidat: "Donald Trump",
//                        persent: 46
//                    ),
//                    (
//                        candidat: "Joe Biden",
//                        persent: 51
//                    ),
//                    (
//                        candidat: "Jo Jorgensen",
//                        persent: 1
//                    )
//                ]
//            )
//        )
//        Self(
//            title: "Президентские выборы в США 2020",
//            desc: "Президентские выборы в США 2020 года станут 59-ми президентскими выборами, проводимыми раз в четыре года",
//            status: .ended(
//                at: Date(timeIntervalSince1970: 1580860800),
//                winners: [
//                    (
//                        candidat: "Donald Trump",
//                        persent: 46
//                    ),
//                    (
//                        candidat: "Joe Biden",
//                        persent: 51
//                    ),
//                    (
//                        candidat: "Jo Jorgensen",
//                        persent: 1
//                    )
//                ]
//            )
//        )
    ]
}

struct FinishedPoll {
    static let title = "Выборы президента России 2024"
    static let desc = "Выборы президента России 2024 года станут восьмыми президентскими выборами."
    static let starts = Date(timeIntervalSince1970: 1710453600)
    
    static let citizenshipCriteria = "Являетесь гражданином России"
    static let ageCriteria = "Вам исполнилось 18 лет в день выборов или до него"
    
    let isCitizen: Bool
    let isAgeValid: Bool
    
    init(nationality: String?, birthday: Date?) {
        if let nationality = nationality {
            isCitizen = nationality == "RUS" || nationality == "РОС" || nationality == "РУС"
        } else {
            isCitizen = false
        }        
        
        if let birthday = birthday {
            let age = Calendar(identifier: .iso8601).dateComponents([.year], from: birthday, to: Date()).year!
            
            isAgeValid = age >= 18
        } else {
            isAgeValid = false
        }
    }
}
