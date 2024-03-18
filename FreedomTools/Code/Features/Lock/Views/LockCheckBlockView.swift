//
//  LockCheckBlockView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 14.03.2024.
//

import SwiftUI

struct LockCheckBlockView: View {
    @EnvironmentObject var lockCheckViewModel: LockCheckView.ViewModel
    
    @State private var remaining = LockStatus.BLOCK_TIME
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ZStack {
                CircularProgressView(
                    progress: Double(remaining) / Double(LockStatus.BLOCK_TIME)
                )
                .frame(width: 150, height: 150)
                Text("\(remaining)")
                    .bold()
                    .font(.system(size: 30))
            }
            ZStack {}
                .frame(height: 30)
            Text("TooManyFailedPasscodes")
                .bold()
                .multilineTextAlignment(.center)
                .frame(width: 300)
                .padding(.bottom)
        }
        .onReceive(timer) { time in
            self.remaining = self.lockCheckViewModel.lockStatus.blockTo - Int(time.timeIntervalSince1970)
            if self.remaining == 0 {
                self.lockCheckViewModel.lockStatus.unblock()
            }
        }
    }
}

#Preview {
    LockCheckBlockView()
        .environmentObject(LockCheckView.ViewModel())
}
