//
//  MainActiveView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 29.02.2024.
//

import SwiftUI

struct MainActiveView: View {
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    let registrationEntity: RegistrationEntity
    
    var body: some View {
        List {
            HStack {
                Spacer()
                ZStack {
                    RegistrationListElemView(registrationEntity: registrationEntity)
                    NavigationLink {
                        RegistrationView(
                            registrationEntity: registrationEntity
                        )
                    } label: {
                        EmptyView()
                    }.opacity(0.0)
                }
                .buttonStyle(.plain)
                .frame(width: 350, height: 190)
                Spacer()
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
        .background(.clear)
        .listStyle(.plain)
    }
}

#Preview {
    MainActiveView(
        registrationEntity: RegistrationEntity.sample
    )
}
