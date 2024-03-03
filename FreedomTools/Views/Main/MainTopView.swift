//
//  MainTopView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 29.02.2024.
//

import SwiftUI

struct MainTopView: View {
    @ObservedObject var appController: AppController
    @Binding var isExiting: Bool
    
    var body: some View {
        HStack {
            Text("Polls")
                .font(.custom("RobotoMono-Bold", size: 25))
                .padding(.leading)
            Spacer()
            LocalizationSwitcherView(appController: appController)
            if appController.identityManager != nil {
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
    MainTopView(
        appController: AppController(),
        isExiting: .constant(false)
    )
}
