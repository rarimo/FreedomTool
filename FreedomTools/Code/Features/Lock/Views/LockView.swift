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
    }
}

#Preview {
    LockView()
        .environmentObject(AppView.ViewModel())
}
