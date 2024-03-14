//
//  LockPasscodePickerProgressorView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 13.03.2024.
//

import SwiftUI

struct LockPasscodePickerProgressorView: View {
    @EnvironmentObject var lockPasscodePickerViewModel: LockPasscodePickerView.ViewModel
    
    var body: some View {
        HStack {
            ForEach(0..<4, id: \.self) { activationStep in
                LockPasscodePickerProgressorStepView(
                    lockPasscodePickerViewModel.passcode
                        .count,
                    activationStep
                )
                Spacer()
                    .frame(width: 32)
            }
        }
    }
}

struct LockPasscodePickerProgressorStepView: View {
    let currentStep: Int
    let activationStep: Int
    
    init(_ currentStep: Int, _ activationStep: Int) {
        self.currentStep = currentStep
        self.activationStep = activationStep
    }
    
    var body: some View {
        Circle()
            .frame(width: 16, height: 16)
            .opacity(currentStep > activationStep ? 1 : 0.1)
    }
}

#Preview {
    LockPasscodePickerProgressorView()
        .environmentObject(LockPasscodePickerView.ViewModel())
}
