//
//  SettingsLanguageView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct SettingsLanguageView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "globe")
                .resizable()
                .frame(width: 15, height: 15)
            ZStack {}
                .frame(width: 1)
            Text("Language")
                .font(.custom("Inter-Regular", size: 14))
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 100)
                    .opacity(0.05)
                HStack {
                    Button(action: {
                        if !self.appViewModel.isRusLocalication {
                            self.appViewModel.switchLocalization()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 100)
                                .foregroundStyle(appViewModel.isRusLocalication ? .white : .clear)
                                .shadow(radius: 1, y: 1)
                            Text("RUS")
                                .font(.custom("Inter-Regular", size: 12))
                                .opacity(appViewModel.isRusLocalication ? 1 : 0.5)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: 57, height: 28)
                    Button(action: {
                        if !self.appViewModel.isEngLocalication {
                            self.appViewModel.switchLocalization()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 100)
                                .foregroundStyle(appViewModel.isEngLocalication ? .white : .clear)
                                .shadow(radius: 1, y: 1)
                            Text("ENG")
                                .font(.custom("Inter-Regular", size: 12))
                                .opacity(appViewModel.isEngLocalication ? 1 : 0.5)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: 57, height: 28)
                }
            }
            .frame(width: 125, height: 32)
        }
    }
}

#Preview {
    SettingsLanguageView()
        .padding()
        .environmentObject(AppView.ViewModel())
}
