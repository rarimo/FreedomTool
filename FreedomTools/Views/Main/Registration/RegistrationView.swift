//
//  RegistrationView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 01.03.2024.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject private var registrationController: RegistrationController = RegistrationController()
    @ObservedObject var appController: AppController
    
    let registrationEntity: RegistrationEntity
    
    init(appController: AppController, registrationEntity: RegistrationEntity) {
        self.appController = appController
        self.registrationEntity = registrationEntity
    }
    
    var body: some View {
        VStack {
            if let isAlreadyRegistered = registrationController.isAlreadyRegistered {
                if isAlreadyRegistered {
                    RegistrationSignedManifestView(registrationEntity: registrationEntity)
                } else {
                    if appController.user == nil && self.registrationController.currentStep == .sign {
                        RegistrationManifestView(registrationEntity: registrationEntity) {
                            self.registrationController.currentStep = .verification
                        }
                    }
                    if appController.user == nil && self.registrationController.currentStep == .verification {
                        RegistrationVerifyView(registrationEntity: registrationEntity) {
                            self.registrationController.currentStep = .mrz
                        }
                    }
                    if appController.user == nil && self.registrationController.currentStep == .mrz {
                        OnboardMRZScannerView(mrzScannerController: registrationController.mrzScannerController)
                    }
                    if appController.user == nil && self.registrationController.currentStep == .nfc {
                        OnboardNFCScannerView(
                            nfcScannerController: registrationController.nfcScannerController,
                            mrzKey: registrationController.mrzScannerController.mrzKey
                        )
                    }
                    if appController.user == nil && self.registrationController.currentStep == .confirm {
                        RegistrationConfirmView(
                            passportModel: self.registrationController.nfcScannerController.nfcModel!
                        ) {
                            self.registrationController.currentStep = .waiting
                        }
                    }
                    if self.registrationController.currentStep == .waiting {
                        RegistrationWaitingView(
                            appController: appController,
                            registrationEntity: registrationEntity,
                            model: self.registrationController.nfcScannerController.nfcModel
                        )
                    }
                }
            } else {
                ProgressView()
                    .controlSize(.large)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(trailing: btnBack)
        .onAppear(perform: {
            initCallbacks()
            checkUserRegistration()
        })
    }
    
    var btnBack : some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            ZStack {
                Circle()
                    .foregroundStyle(.clear)
                Image(systemName: "xmark")
            }
            .frame(width: 50, height: 50)
        }
        .buttonStyle(.plain)
    }
    
    func initCallbacks() {
        if self.appController.user != nil {
            self.registrationController.currentStep = .waiting
        }
        
        self.registrationController.mrzScannerController.setOnScanned {
            self.registrationController.currentStep = .nfc
        }
        
        self.registrationController.nfcScannerController.setOnScanned {
            self.registrationController.currentStep = .confirm
        }
        
        self.registrationController.nfcScannerController.setOnError {
            self.registrationController.currentStep = .mrz
        }
    }
    
    func checkUserRegistration() {
        if appController.identityManager == nil  {
            registrationController.isAlreadyRegistered = false
            
            return
        }
        
        Task {
            let isUserRegistered = try await appController.isUserRegistered(
                address: registrationEntity.address
            )
            
            DispatchQueue.main.async {
                registrationController.isAlreadyRegistered = isUserRegistered
            }
        }
                
        registrationController.isAlreadyRegistered = false
    }
}

#Preview {
    RegistrationView(
        appController: AppController(),
        registrationEntity: RegistrationEntity.sample
    )
}
