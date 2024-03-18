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
                        .font(.custom("Inter-Medium", size: 15))
                    Spacer()
                }
                .padding(.leading)
                .frame(height: 60)
                HStack {
                    Text(
                        registrationEntity.remark.excerpt != ""
                        ? registrationEntity.remark.excerpt
                        : registrationEntity.remark.description
                    )
                        .font(.custom("Inter-Regular", size: 13))
                        .opacity(0.6)
                    Spacer()
                }
                .padding(.leading)
                Spacer()
                if registrationEntity.remark.isActive ?? false {
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
                    }
                    .padding(.bottom)
                    .padding(.horizontal)
                }
            }
        }
    }
}

#Preview {
    RegistrationListElemView(registrationEntity: RegistrationEntity.sample)
}
