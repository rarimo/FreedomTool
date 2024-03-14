//
//  LockPasscodePickerBoardView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 13.03.2024.
//

import SwiftUI

struct LockPasscodePickerBoardView: View {
    @EnvironmentObject var lockPasscodePickerViewModel: LockPasscodePickerView.ViewModel
    
    var body: some View {
        VStack {
            HStack {
                ForEach(1..<4, id: \.self) { row in
                    VStack {
                        ForEach(0..<3, id: \.self) { column in
                            LockPasscodePickerBoardCodeButtonView(row + (column * 3))
                        }
                    }
                }
            }
            HStack {
                ZStack {}
                    .frame(width: 124.67, height: 64)
                LockPasscodePickerBoardCodeButtonView(0)
                LockPasscodePickerBoardCodeCancelButtonView()
            }
        }
    }
}

struct LockPasscodePickerBoardCodeButtonView: View {
    @EnvironmentObject var lockPasscodePickerViewModel: LockPasscodePickerView.ViewModel
    
    let number: Int
    
    init(_ number: Int) {
        self.number = number
    }
    
    var body: some View {
        Button(action: {
            lockPasscodePickerViewModel.push(number)
        }) {
            ZStack {
                Rectangle()
                    .foregroundStyle(.white)
                Text(number.description)
                    .font(.system(size: 20))
                    .bold()
            }
        }
        .frame(width: 124.67, height: 64)
        .buttonStyle(.plain)
    }
}

struct LockPasscodePickerBoardCodeCancelButtonView: View {
    @EnvironmentObject var lockPasscodePickerViewModel: LockPasscodePickerView.ViewModel
    
    var body: some View {
        Button(action: {
            lockPasscodePickerViewModel.removeLast()
        }) {
            ZStack {
                Rectangle()
                    .foregroundStyle(.white)
                Image(systemName: "xmark.square")
                    .resizable()
                    .frame(width: 17.5, height: 13.75)
            }
        }
        .frame(width: 124.67, height: 64)
        .buttonStyle(.plain)
    }
}

#Preview {
    LockPasscodePickerBoardView()
        .environmentObject(LockPasscodePickerView.ViewModel())
}
