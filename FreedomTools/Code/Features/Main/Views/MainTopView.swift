//
//  MainTopView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 29.02.2024.
//

import SwiftUI

struct MainTopView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @Binding var isSettingsActive: Bool
    
    var body: some View {
        HStack {
            Text("Polls")
                .font(.custom("Inter-Bold", size: 25))
                .padding(.leading)
            Spacer()
            Button(action: {
                isSettingsActive = true
            }) {
                ZStack {
                    Circle()
                        .foregroundStyle(.second)
                    Image(systemName: "gearshape")
                }
            }
            .frame(width: 50, height: 50)
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    MainTopView(isSettingsActive: .constant(false))
        .environmentObject(AppView.ViewModel())
}
