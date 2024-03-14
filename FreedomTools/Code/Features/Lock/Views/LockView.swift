//
//  LockView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 13.03.2024.
//

import SwiftUI

struct LockView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            if let passcode = viewModel.passcode {
                LockCheckView(passcode)
            } else {
                LockRegisterPasscodeView()
            }
        }
//            .onAppear {
//                viewModel.setOnSeccess {
//                    appViewModel.isLocked = false
//                }
//                
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    do {
//                        try viewModel.authByFaceID()
//                    } catch let error {
//                        print("Auth error: \(error)")
//                    }
//                }
//            }
    }
}

#Preview {
    LockView()
        .environmentObject(AppView.ViewModel())
}
