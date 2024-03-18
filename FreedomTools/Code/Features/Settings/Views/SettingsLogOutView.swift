//
//  SettingsLogOutView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct SettingsLogOutView: View {
    var body: some View {
        HStack {
            Image("Exit")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.blood)
                .frame(width: 15, height: 15)
            ZStack {}
                .frame(width: 1)
            Text("Logout")
                .foregroundStyle(.blood)
                .font(.custom("Inter-Regular", size: 14))
            Spacer()
        }
    }
}

#Preview {
    SettingsLogOutView()
        .padding()
}
