//
//  RegistrationManifestView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 01.03.2024.
//

import SwiftUI

struct RegistrationManifestView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let registrationEntity: RegistrationEntity
    
    let onSign: () -> Void
    
    var body: some View {
        VStack {
            RegistrationDetailsHeaderView(registrationEntity: registrationEntity)
            VStack(alignment: .trailing) {
                Spacer()
                    .frame(height: 30)
                HStack {
                    Text("Heading")
                        .font(.custom("RobotoSlab-Bold", size: 14))
                        .opacity(0.5)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                    .frame(height: 5)
                HStack {
                    Text(registrationEntity.remark.excerpt)
                        .font(.custom("RobotoMono-Regular", size: 14))
                        .opacity(0.5)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                    .frame(height: 30)
                HStack {
                    Text("Description")
                        .font(.custom("RobotoSlab-Bold", size: 14))
                        .opacity(0.5)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                    .frame(height: 5)
                ScrollView {
                    HStack {
                        Text(registrationEntity.remark.description)
                            .font(.custom("RobotoMono-Regular", size: 14))
                            .opacity(0.5)
                        Spacer()
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
            Divider()
            Spacer()
                .frame(height: 15)
            (
            Text("\(registrationEntity.info.counters.totalRegistrations.description) ")
                .font(.custom("RobotoMono-SemiBold", size: 12))
            +
            Text("PeopleAlreadySigned")
                .font(.custom("RobotoMono-Regular", size: 12))
            )
            .opacity(0.5)
            Spacer()
                .frame(height: 15)
            if
                self.registrationEntity.remark.isActive ?? true
                    && !self.registrationEntity.isEnded()
            {
                Button(action: onSign) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 1_000)
                            .foregroundStyle(.second)
                        HStack {
                            Image("person_add")
                                .resizable()
                                .frame(width: 17.6, height: 12.18)
                            Spacer()
                                .frame(width: 15)
                            Text("Sign")
                                .font(.custom("RobotoMono-Bold", size: 14))
                        }
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 341, height: 48)
            }
        }
    }
}

#Preview {
    RegistrationManifestView(registrationEntity: RegistrationEntity.sample) {}
}
