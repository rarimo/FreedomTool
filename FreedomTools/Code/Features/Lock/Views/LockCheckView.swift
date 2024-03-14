//
//  LockCheckView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 14.03.2024.
//

import SwiftUI

struct LockCheckView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    let passcode: String
    
    @State private var isInvalidPasscodeAlert = false
    
    @StateObject private var lockStatus = LockStatus.load()
    
    init(_ passcode: String) {
        self.passcode = passcode
    }
    
    var body: some View {
        VStack {
            if lockStatus.isBlocked {
                LockCheckBlockView(lockStatus: lockStatus)
            } else {
                if !isInvalidPasscodeAlert {
                    Spacer()
                    LockCheckPasscodeHeaderView()
                    Spacer()
                    LockPasscodePickerView() { passcode in
                        if self.passcode == passcode.concatenetedString {
                            self.appViewModel.isLocked = false
                            
                            return
                        }
                        
                        lockStatus.recordFailedAttempt()
                        
                        isInvalidPasscodeAlert = true
                    }
                }
            }
        }
        .alert("InvalidPasscode", isPresented: $isInvalidPasscodeAlert) {
            Button("Ok") {}
        }
    }
}

struct LockCheckPasscodeHeaderView: View {
    var body: some View {
        LockHeaderView(title: "EnterPasscode", subTitle: "")
    }
}

#Preview {
    LockCheckView("1234")
        .environmentObject(AppView.ViewModel())
}
