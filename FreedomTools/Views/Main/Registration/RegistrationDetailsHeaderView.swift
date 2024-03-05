//
//  RegistrationDetailsHeaderView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 01.03.2024.
//

import SwiftUI

struct RegistrationDetailsHeaderView: View {
    let registrationEntity: RegistrationEntity
    
    var body: some View {
        HStack {
            Text(registrationEntity.remark.name)
                .font(.custom("RobotoMono-Bold", size: 20))
                .padding()
            Spacer()
        }
        HStack {
            Image("Calendar")
                .resizable()
                .frame(width: 15, height: 15)
                .padding(.leading)
            RegistrationStatusView(registrationEntity: registrationEntity)
            Spacer()
        }
    }
}

#Preview {
    RegistrationDetailsHeaderView(registrationEntity: RegistrationEntity.sample)
}
