//
//  RegistrationListElemView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 29.02.2024.
//

import SwiftUI

struct RegistrationListElemView: View {
    let registrationEntity: RegistrationEntity
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(.white)
                .shadow(radius: 1, x: 0, y: 1)
            VStack {
                HStack {
                    Text(registrationEntity.remark.name)
                        .font(.custom("RobotoMono-Medium", size: 15))
                    Spacer()
                }
                .padding(.leading)
                .frame(height: 60)
                HStack {
                    Text(registrationEntity.remark.excerpt)
                        .font(.custom("RobotoMono-Regular", size: 12))
                        .opacity(0.6)
                    Spacer()
                }
                .padding(.leading)
                Spacer()
                Divider()
                    .frame(width: 320)
                Spacer()
                    .frame(height: 10)
                HStack {
                    Image("Calendar")
                        .resizable()
                        .frame(width: 20, height: 20)
                    RegistrationStatusView(registrationEntity: registrationEntity)
                    Spacer()
                    Image("Manifest")
                        .resizable()
                        .frame(width: 66, height: 20)
                }
                .padding(.bottom)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    RegistrationListElemView(registrationEntity: RegistrationEntity.sample)
}
