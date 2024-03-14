//
//  LockPasscodePickerView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 13.03.2024.
//

import SwiftUI

struct LockPasscodePickerView: View {
    @StateObject private var viewModel = ViewModel()
    
    let onFull: ([Int]) -> Void
    
    init(_ onFull: @escaping ([Int]) -> Void) {
        self.onFull = onFull
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                    .frame(width: 28)
                LockPasscodePickerProgressorView()
            }
            Spacer()
                .frame(height: 150)
            LockPasscodePickerBoardView()
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.setOnFull(onFull)
        }
    }
}


#Preview {
    LockPasscodePickerView() { _ in}
}
