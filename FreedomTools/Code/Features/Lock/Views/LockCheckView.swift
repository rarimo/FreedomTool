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
    
    @StateObject private var viewModel = ViewModel()
    
    init(_ passcode: String) {
        self.passcode = passcode
    }
    
    var body: some View {
        VStack {
            if self.viewModel.lockStatus.isBlocked {
                LockCheckBlockView()
            } else {
                if !self.viewModel.isInvalidPasscodeAlert {
                    Spacer()
                    LockCheckPasscodeHeaderView()
                    Spacer()
                    LockPasscodePickerView() { passcode in
                        if self.passcode == passcode.concatenetedString {
                            self.appViewModel.isLocked = false
                            
                            return
                        }
                        
                        self.viewModel.lockStatus.recordFailedAttempt()
                        
                        self.viewModel.isInvalidPasscodeAlert = true
                    }
                }
            }
        }
        .alert("InvalidPasscode", isPresented: $viewModel.isInvalidPasscodeAlert) {
            Button("Ok") {}
        }
        .onAppear {
            if viewModel.faceIDChoise {
                self.viewModel.setOnSeccessFaceID {
                    appViewModel.isLocked = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    do {
                        try viewModel.authByFaceID()
                    } catch let error {
                        print("Auth error: \(error)")
                    }
                }
            }
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
