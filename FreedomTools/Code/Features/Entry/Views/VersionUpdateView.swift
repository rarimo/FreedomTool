//
//  VersionUpdateView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 14.03.2024.
//

import SwiftUI

struct VersionUpdateView: View {    
    var body: some View {
        VStack {
            Text("NewVersion")
                .multilineTextAlignment(.center)
                .bold()
                .frame(width: 300)
        }
    }
}

#Preview {
    VersionUpdateView()
}
