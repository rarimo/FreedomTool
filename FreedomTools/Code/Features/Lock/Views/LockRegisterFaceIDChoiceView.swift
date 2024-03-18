//
//  LockRegisterFaceIDChoiceView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct LockRegisterFaceIDChoiceView: View {
    let onChoice: (Bool) -> Void
    
    var body: some View {
        VStack {
            Spacer()
            LockRegisterHintFaceIDView()
            Spacer()
            Divider()
            ZStack {}
                .frame(height: 1)
            Button(action: {
                self.onChoice(true)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 1_000)
                        .foregroundStyle(.second)
                    Text("Enable")
                        .font(.custom("RobotoMono-Semibold", size: 14))
                }
            }
            .buttonStyle(.plain)
            .frame(width: 326, height: 50)
            Button(action: {
                self.onChoice(false)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 1_000)
                        .foregroundStyle(.white)
                    Text("MaybeLater")
                        .font(.custom("RobotoMono-Semibold", size: 14))
                }
            }
            .buttonStyle(.plain)
            .frame(width: 326, height: 50)
        }
    }
}

struct LockRegisterHintFaceIDView: View {
    var body: some View {
        LockRegisterHintTemplateView(iconName: "FaceIDIcon", text: "EnableFaceID")
    }
}

#Preview {
    LockRegisterFaceIDChoiceView() { _ in }
}
