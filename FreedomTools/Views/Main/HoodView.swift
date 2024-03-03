//
//  HoodView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 29.02.2024.
//

import SwiftUI

struct HoodView: View {
    var body: some View {
        VStack {
            Image("Hood")
                .resizable()
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.size.width, height: 200)
            Spacer()
        }
    }
}

#Preview {
    HoodView()
}
