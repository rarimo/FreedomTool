//
//  LockHeaderView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 13.03.2024.
//

import SwiftUI

struct LockHeaderView: View {
    let title: String
    let subTitle: String
    
    var body: some View {
        VStack {
            Text(LocalizedStringKey(title))
                .font(.custom("Inter-Bold", size: 32))
                .bold()
            Spacer()
                .frame(height: 15)
            Text(LocalizedStringKey(subTitle))
                .font(.system(size: 14))
                .opacity(0.56)
                .frame(width: 252)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    LockHeaderView(title: "EnterPasscode", subTitle: "RememberPasscode")
}
