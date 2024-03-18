//
//  MainTopView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 29.02.2024.
//

import SwiftUI

struct MainTopView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @Binding var isExiting: Bool
    
    var body: some View {
        HStack {
            Text("Polls")
                .font(.custom("Inter-Bold", size: 25))
                .padding(.leading)
            Spacer()
            LocalizationSwitcherView()
            if appViewModel.identityManager != nil {
                Rectangle()
                    .frame(width: 1, height: 25)
                    .opacity(0.05)
                Button(action: {
                    isExiting = true
                }) {
                    ZStack {
                        Circle()
                            .foregroundStyle(.clear)
                        Image("Exit")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .frame(width: 40, height: 40)
            }
        }
    }
}

#Preview {
    MainTopView(isExiting: .constant(false))
        .environmentObject(AppView.ViewModel())
}
