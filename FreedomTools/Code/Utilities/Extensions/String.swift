//
//  String.swift
//  FreedomTools
//
//  Created by Ivan Lele on 13.03.2024.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

extension Array where Element == Int {
    var concatenetedString: String {
        self.reduce("") { result, value in
            result + value.description
        }
    }
}
