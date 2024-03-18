//
//  SettingsView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppView.ViewModel
    
    @Binding var isActive: Bool
    @Binding var isLoggingOut: Bool
    
    var body: some View {
        VStack {
            ZStack {}
                .frame(height: 5)
            SettingsHeader() {
                isActive = false
            }
            .padding(.horizontal)
            Divider()
            SettingsLanguageView()
                .padding()
            Divider()
                .frame(width: 380)
            SettingsFaceIDView()
                .padding()
            if appViewModel.user == nil {
                Divider()
                    .frame(width: 380)
                Button(action: {
                    self.isLoggingOut = true
                }) {
                    SettingsLogOutView()
                }
                .buttonStyle(.plain)
                .padding()
            }
            Spacer()
        }
    }
}

struct SettingsHeader: View {
    let onClose: () -> Void
    
    var body: some View {
        HStack {
            Text("Settings")
                .font(.custom("Inter-Bold", size: 20))
            Spacer()
            Button(action: onClose) {
                ZStack {
                    Circle()
                        .foregroundStyle(.white)
                        
                    Image(systemName: "xmark")
                        .opacity(0.56)
                }
            }
            .buttonStyle(.plain)
            .frame(width: 50, height: 50)
        }
    }
}

#Preview {
    SettingsView(isActive: .constant(true), isLoggingOut: .constant(false))
        .environmentObject(AppView.ViewModel())
}
