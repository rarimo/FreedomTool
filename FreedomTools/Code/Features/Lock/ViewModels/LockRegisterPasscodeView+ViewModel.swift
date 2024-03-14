//
//  LockRegisterPasscodeView+ViewModel.swift
//  FreedomTools
//
//  Created by Ivan Lele on 13.03.2024.
//

import Foundation

extension LockRegisterPasscodeView {
    class ViewModel: ObservableObject {
        @Published var passcode: [Int] = []
    }
}
