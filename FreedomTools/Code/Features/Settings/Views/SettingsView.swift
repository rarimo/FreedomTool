//
//  SettingsView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Spacer()
            SettingsHeader() {}
                .padding()
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
        }
    }
}

#Preview {
    SettingsView()
}
