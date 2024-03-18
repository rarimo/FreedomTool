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
    
    var body: some View {
        VStack {
            if let faceIDChoice = self.viewModel.faceIDChoice {
                if viewModel.isPasscodeEntering {
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
                                self.viewModel.isInvalidPasscodeAlert = true
                                
                                return
                            }
                            
                            StorageUtils.setPasscode(passcode.concatenetedString)
                            StorageUtils.setFaceIDChoice(faceIDChoice)
                            
                            self.appViewModel.isLocked = false
                        }
                    }
                } else {
                    LockRegisterPasscodeEnableView {
                        self.viewModel.isPasscodeEntering = true
                    }
                }
            } else {
                LockRegisterFaceIDChoiceView { choice in
                    self.viewModel.faceIDChoice = choice
                }
            }
        }
        .alert("PasscodesDoNotMatch", isPresented: $viewModel.isInvalidPasscodeAlert) {
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
