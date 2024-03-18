//
//  SettingsFaceIDView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 18.03.2024.
//

import SwiftUI

struct SettingsFaceIDView: View {
    @State private var isFaceID = StorageUtils.getFaceIDChoice()
    
    var body: some View {
        HStack {
            Image("FaceIDIcon")
                .resizable()
                .frame(width: 15, height: 15)
            ZStack {}
                .frame(width: 1)
            Toggle("Face ID", isOn: $isFaceID)
                .font(.custom("Inter-Regular", size: 14))
        }
        .onChange(of: isFaceID) { change in
            StorageUtils.setFaceIDChoice(change)
        }
    }
}

#Preview {
    SettingsFaceIDView()
        .padding()
}
