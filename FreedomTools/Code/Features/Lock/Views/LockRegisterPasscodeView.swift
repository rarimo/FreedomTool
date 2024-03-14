//
//  LockRegisterPasscodeView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 13.03.2024.
//

import SwiftUI

struct LockRegisterPasscodeView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @StateObject private var viewModel = ViewModel()
    
    @State var isInvalidPasscodeAlert = false
    
    var body: some View {
        VStack {
            Spacer()
            if self.viewModel.passcode.isEmpty {
                LockRegisterPasscodeRegisterFirstView()
                Spacer()
                LockPasscodePickerView { passcode in
                    self.viewModel.passcode = passcode
                }
            } else {
                LockRegisterPasscodeRegisterSecondView()
                Spacer()
                LockPasscodePickerView { passcode in
                    if self.viewModel.passcode != passcode {
                        self.isInvalidPasscodeAlert = true
                        
                        return
                    }
                    
                    StorageUtils.setPasscode(passcode.concatenetedString)
                    
                    self.appViewModel.isLocked = false
                }
            }
        }
        .alert("PasscodesDoNotMatch", isPresented: $isInvalidPasscodeAlert) {
            Button("Ok") {
                self.viewModel.passcode = []
            }
        }
    }
}

struct LockRegisterPasscodeRegisterFirstView: View {
    var body: some View {
        LockHeaderView(title: "EnterPasscode", subTitle: "RememberPasscode")
    }
}

struct LockRegisterPasscodeRegisterSecondView: View {
    var body: some View {
        LockHeaderView(title: "RepeatPasscode", subTitle: "RememberPasscode")
    }
}

#Preview {
    LockRegisterPasscodeView()
        .environmentObject(AppView.ViewModel())
}
