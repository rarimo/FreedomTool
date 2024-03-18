//
//  LockRegisterPasscodeEnableView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct LockRegisterPasscodeEnableView: View {
    let onEnable: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            LockRegisterHintPasscodeView()
            Spacer()
            Divider()
            ZStack {}
                .frame(height: 1)
            Button(action: {
                self.onEnable()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 1_000)
                        .foregroundStyle(.second)
                    Text("Enter")
                        .font(.custom("RobotoMono-Semibold", size: 14))
                }
            }
            .buttonStyle(.plain)
            .frame(width: 326, height: 50)
        }
    }
}

struct LockRegisterHintPasscodeView: View {
    var body: some View {
        LockRegisterHintTemplateView(iconName: "PasscodeIcon", text: "SetUpPasscode")
    }
}

#Preview {
    LockRegisterPasscodeEnableView() {}
}
