//
//  RegistrationWaitingCheckboxesView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 02.03.2024.
//

import SwiftUI

struct RegistrationWaitingCheckboxesView: View {
    @Binding var stepper: Int;
    
    var body: some View {
        VStack {
            HStack {
                Text("FormationOfTheSignature")
                    .font(.custom("RobotoSlab-Regular", size: 14))
                Spacer()
                if stepper >= 1 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.second)
                        HStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 13.58, height: 10.02)
                            Text("Done")
                                .font(.custom("RobotoSlab-SemiBold", size: 12))
                        }
                    }
                    .frame(width: 100, height: 30)
                } else {
                    Text("Loading")
                        .font(.custom("RobotoSlab-Regular", size: 14))
                        .opacity(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            HStack {
                Text("Anonymization")
                    .font(.custom("RobotoMono-Regular", size: 14))
                Spacer()
                if stepper >= 2 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.second)
                        HStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 13.58, height: 10.02)
                            Text("Done")
                                .font(.custom("RobotoSlab-SemiBold", size: 12))
                        }
                    }
                    .frame(width: 100, height: 30)
                } else {
                    Text("Loading")
                        .font(.custom("RobotoSlab-Regular", size: 14))
                        .opacity(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            HStack {
                Text("SendingSignature")
                    .font(.custom("RobotoMono-Regular", size: 14))
                Spacer()
                if stepper >= 3 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.second)
                        HStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 13.58, height: 10.02)
                            Text("Done")
                                .font(.custom("RobotoSlab-SemiBold", size: 12))
                        }
                    }
                    .frame(width: 100, height: 30)
                } else {
                    Text("Loading")
                        .font(.custom("RobotoSlab-Regular", size: 14))
                        .opacity(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            HStack {
                Text("Finalizing")
                    .font(.custom("RobotoMono-Regular", size: 14))
                Spacer()
                if stepper >= 4 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.second)
                        HStack {
                            Image(systemName: "checkmark")
                                .resizable()
                                .frame(width: 13.58, height: 10.02)
                            Text("Done")
                                .font(.custom("RobotoSlab-SemiBold", size: 12))
                        }
                    }
                    .frame(width: 100, height: 30)
                } else {
                    Text("Loading")
                        .font(.custom("RobotoSlab-Regular", size: 14))
                        .opacity(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}

#Preview {
    RegistrationWaitingCheckboxesView(stepper: .constant(0))
}
