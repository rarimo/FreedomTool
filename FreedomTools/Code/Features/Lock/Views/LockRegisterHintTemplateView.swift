//
//  LockRegisterHintTemplateView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct LockRegisterHintTemplateView: View {
    let iconName: String
    let text: String
    
    var body: some View {
        VStack {
            Image(iconName)
            ZStack {}
                .frame(height: 20)
            Text(LocalizedStringKey(text))
                .font(.system(size: 32))
                .bold()
                .multilineTextAlignment(.center)
                .frame(width: 145)
        }
    }
}

#Preview {
    LockRegisterHintTemplateView(iconName: "FaceIDIcon", text: "EnableFaceID")
}
