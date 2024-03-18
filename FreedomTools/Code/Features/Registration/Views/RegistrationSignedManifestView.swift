//
//  RegistrationSignedManifestView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 01.03.2024.
//

import SwiftUI

struct RegistrationSignedManifestView: View {
    let registrationEntity: RegistrationEntity
    
    var body: some View {
        VStack {
            RegistrationDetailsHeaderView(registrationEntity: registrationEntity)
            Spacer()
                .frame(height: 20)
            ZStack {
                Image("SignedManifestBackground")
                    .resizable()
                HStack {
                    VStack {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 100)
                                    .foregroundStyle(.second)
                                HStack {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .frame(width: 13.58, height: 10.02)
                                    Text("Signed")
                                        .font(.custom("Inter-Semibold", size: 12))
                                }
                            }
                            .frame(width: 100, height: 28)
                            Spacer()
                        }
                        Spacer()
                            .frame(height: 10)
                        HStack {
                            (
                                Text("YouAnd")
                                    .font(.custom("Inter-Semibold", size: 14))
                                +
                                Text(" \((registrationEntity.info.counters.totalRegistrations > 0 ? registrationEntity.info.counters.totalRegistrations-1 : 0).description) ")
                                    .font(.custom("Inter-Semibold", size: 14))
                                +
                                Text("OtherPeopleAlreadySigned")
                                    .font(.custom("Inter-Regular", size: 14))
                            )
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .frame(width: 358, height: 115)
            Spacer()
                .frame(height: 30)
            Divider()
            VStack(alignment: .trailing) {
                Spacer()
                    .frame(height: 30)
                HStack {
                    Text("Heading")
                        .font(.custom("Inter-Bold", size: 14))
                        .opacity(0.5)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                    .frame(height: 5)
                HStack {
                    Text(registrationEntity.remark.excerpt)
                        .font(.custom("Inter-Regular", size: 14))
                        .opacity(0.5)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                    .frame(height: 30)
                HStack {
                    Text("Description")
                        .font(.custom("Inter-Bold", size: 14))
                        .opacity(0.5)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                    .frame(height: 5)
                ScrollView {
                    HStack {
                        Text(registrationEntity.remark.description)
                            .font(.custom("Inter-Regular", size: 14))
                            .opacity(0.5)
                        Spacer()
                    }
                }
                .padding(.horizontal)
            }
            Spacer()
        }
    }
}

#Preview {
    RegistrationSignedManifestView(registrationEntity: RegistrationEntity.sample)
}
