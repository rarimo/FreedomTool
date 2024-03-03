//
//  MainActiveView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 29.02.2024.
//

import SwiftUI

struct MainActiveView: View {
    @ObservedObject var appController: AppController
    let registrationEntity: RegistrationEntity
    
    var body: some View {
        List {
            ZStack {
                RegistrationListElemView(registrationEntity: registrationEntity)
                NavigationLink {
                    RegistrationView(
                        appController: appController,
                        registrationEntity: registrationEntity
                    )
                } label: {
                    EmptyView()
                }.opacity(0.0)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .buttonStyle(.plain)
            .frame(width: 350, height: 190)
            
        }
        .scrollContentBackground(.hidden)
        .background(.clear)
        .listStyle(.plain)
    }
}

#Preview {
    MainActiveView(appController: AppController(), registrationEntity: RegistrationEntity.sample)
}
