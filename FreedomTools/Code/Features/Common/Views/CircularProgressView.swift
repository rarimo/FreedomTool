//
//  CircularProgressView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 14.03.2024.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.gray.opacity(0.1),
                    lineWidth: 20
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.second,
                    style: StrokeStyle(
                        lineWidth: 20
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)

        }
    }
}

#Preview {
    CircularProgressView(progress: 0.5)
        .frame(width: 150, height: 150)
}
