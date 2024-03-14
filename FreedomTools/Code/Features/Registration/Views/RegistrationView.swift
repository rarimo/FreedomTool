//
//  RegistrationView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 01.03.2024.
//

import SwiftUI

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
    @StateObject private var registrationController: RegistrationController = RegistrationController()
    
    @State private var isErrorAlertPresent = false
    @State private var errorMessage = ""
    
    let registrationEntity: RegistrationEntity
    
    var body: some View {
        VStack {
            if let isAlreadyRegistered = registrationController.isAlreadyRegistered {
                if isAlreadyRegistered {
                    RegistrationSignedManifestView(registrationEntity: registrationEntity)
                } else {
                    if self.registrationController.currentStep == .sign {
                        RegistrationManifestView(registrationEntity: registrationEntity) {
                            self.registrationController.currentStep = .verification
                        }
                    }
                    if self.registrationController.currentStep == .verification {
                        RegistrationVerifyView(registrationEntity: registrationEntity) {
                            self.registrationController.currentStep = .mrz
                        }
                    }
                    if self.registrationController.currentStep == .mrz {
                        RegisterMRZScannerView(mrzScannerController: registrationController.mrzScannerController)
                    }
                    if self.registrationController.currentStep == .nfc {
                        RegisterNFCScannerView(
                            nfcScannerController: registrationController.nfcScannerController,
                            mrzKey: registrationController.mrzScannerController.mrzKey
                        )
                    }
                    if self.registrationController.currentStep == .confirm {
                        RegistrationConfirmView(
                            passportModel: self.registrationController.nfcScannerController.nfcModel!
                        ) {
                            self.registrationController.currentStep = .waiting
                        }
                    }
                    if self.registrationController.currentStep == .waiting {
                        RegistrationWaitingView(
                            registrationController: registrationController,
                            registrationEntity: registrationEntity,
                            model: self.registrationController.nfcScannerController.nfcModel,
                            isErrorAlertPresent: $isErrorAlertPresent,
                            errorMessage: $errorMessage
                        )
                    }
                }
            } else {
                ZStack {
                    Color.white.ignoresSafeArea()
                    ProgressView()
                        .controlSize(.large)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(trailing: btnBack)
        .onAppear(perform: {
            initCallbacks()
            checkUserRegistration()
        })
        .alert(isPresented: $isErrorAlertPresent) {
            Alert(
                title: Text("ErrorTitle"),
                message: Text(LocalizedStringKey(errorMessage)),
                dismissButton: .default(Text("Ok"))
            )
        }
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
        if self.appViewModel    .user != nil {
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
        if appViewModel.identityManager == nil  {
            registrationController.isAlreadyRegistered = false
            
            return
        }
        
        Task {
            let isUserRegistered = try await appViewModel.isUserRegistered(
                address: registrationEntity.address
            )
            
            DispatchQueue.main.async {
                registrationController.isAlreadyRegistered = isUserRegistered
            }
        }
    }
}

#Preview {
    RegistrationView(
        registrationEntity: RegistrationEntity.sample
    )
    .environmentObject(AppView.ViewModel())
}
