//
//  RegistrationWaitingView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 02.03.2024.
//

import Web3
import SwiftUI
import NFCPassportReader

struct RegistrationWaitingView: View {
    @ObservedObject var appController: AppController
    @ObservedObject var registrationController: RegistrationController
    let registrationEntity: RegistrationEntity
    
    let model: NFCPassportModel?
    
    @Binding var isErrorAlertPresent: Bool
    @Binding var errorMessage: String
    
    @State private var isDone = false
    @State private var viewPetitionActive = false
    @State private var waitingStepper = 0;
    
    @State private var checkingTask: Task = Task {}
    
    var body: some View {
        VStack {
            Spacer()
            if isDone {
                LottieView(animationFileName: "checkbox", loopMode: .playOnce)
                    .frame(width: 110,  height: 110)
            } else {
                LottieView(animationFileName: "loader", loopMode: .loop)
                    .frame(width: 125,  height: 125)
            }
            Text(LocalizedStringKey(isDone ? "AllDone" : "PleaseWait"))
                .font(.custom("RobotoMono-Semibold", size: 20))
                .multilineTextAlignment(.center)
                .frame(width: 300, height: 60)
            if !isDone {
                Text("PleaseWaitSub")
                    .font(.custom("RobotoMono-Regular", size: 15))
                    .multilineTextAlignment(.center)
                    .opacity(0.5)
                    .frame(width: 250)
            }
            Spacer()
                .frame(height: 30)
            Divider()
                .frame(width: 350)
            RegistrationWaitingCheckboxesView(stepper: $waitingStepper)
            Spacer()
            if isDone {
                Button(action: {
                    viewPetitionActive = true
                }) {
                    Text("ViewManifest")
                        .font(.custom("RobotoMono-Bold", size: 14))
                }
                .buttonStyle(.plain)
            } else {
                VStack {
                    Divider()
                    (
                        Text("Remember")
                            .font(.custom("RobotoMono-Medium", size: 11)) +
                        Text("RememberHint")
                            .font(.custom("RobotoMono-Regular", size: 11))
                    )
                    .multilineTextAlignment(.center)
                    .opacity(0.5)
                    .padding(.top)
                }
                .padding()
            }
        }
        .sheet(isPresented: $viewPetitionActive) {
            RegistrationSignedManifestView(registrationEntity: registrationEntity)
        }
        .onAppear(perform: self.wait)
        .onDisappear {
            checkingTask.cancel()
        }
    }
    
    func wait() {
        let task = Task { @MainActor in
            do {
                if appController.user == nil {
                    let userID = try model!.getIdentidier()
                    
                    if try UserStorage.isUserExist(id: userID) {
                        try appController.loadUser(userId: userID)
                    } else {
                        do {
                           try validateModel()
                        } catch let error {
                            self.registerHandledError(error)
                            
                            return
                        }
                        
                        do {
                            try await appController.newUser(model!)
                        } catch let error {
                            if "\(error)".contains("ErrorTooManyRequest") {
                                self.registerHandledError("ErrorTooManyRequest")
                                
                                return
                            }
                            
                            throw error
                        }
                    }
                }
                
                waitingStepper += 1
                
                if appController.user!.requestedIn.contains(registrationEntity.address) {
                    waitingStepper += 2
                } else {
                    var isFinalized = false
                    while !isFinalized {
                        isFinalized = try appController.isUserFinalized()
                        // sleep 10 second
                        try await Task.sleep(nanoseconds: 10_000_000_000)
                    }
                    
                    waitingStepper += 1
                    
                    do {
                        let txHash = try await appController.register(address: registrationEntity.address)
                        
                        print("register tx hash: \(txHash)")
                    } catch let error {
                        if "\(error)".contains("no non-revoked credentials found") {
                            try self.appController.eraceUser()
                            
                            self.registerHandledError("ErrorIdentityRevoked")
                            
                            return
                        }
                        
                        if "\(error)".contains("user already registered") {
                            self.registerHandledError("ErrorYouAlredySigned")
                            
                            return
                        }
                        
                        throw error
                    }
                    
                    var updatedUser = appController.user!
                    updatedUser.requestedIn.append(registrationEntity.address)
                    
                    waitingStepper += 1
                        
                    try! appController.updateUser(updatedUser)
                }
                
                var isReqistered = false
                while !isReqistered {
                    isReqistered = try await appController.isUserRegistered(
                        address: registrationEntity.address
                    )
                    // sleep 10 second
                    try await Task.sleep(nanoseconds: 10_000_000_000)
                }
                
                waitingStepper += 1
                self.isDone = true
            } catch let error {
                print("Waiting error: \(error)")
            }
        }
        
        self.checkingTask = task
    }
    
    func registerHandledError(_ error: Error) {
        if !error.isCancelled {
            errorMessage = "\(error)"
            isErrorAlertPresent = true
            
            appController.identityManager = nil
            appController.user = nil
            
            registrationController.currentStep = .sign
        }
    }
    
    func validateModel() throws {
        let model = registrationController.nfcScannerController.nfcModel!
        
        let birthday = model.dateOfBirth.parsableDateToDate()
        let age = birthday.age()
        if age < 18 {
            throw "ErrorIsNotAdult"
        }
        
        let expityDate = model.documentExpiryDate.parsableDateToDate()
        if Date() > expityDate {
            throw "ErrorYourDocumentExpired"
        }
        
        if registrationEntity.issuingAuthorityWhitelist.isEmpty {
            return
        }
        
        let issuingAuthorityCodeStr = model.issuingAuthority.reversedInt()
        let issuingAuthorityCode = BigUInt(issuingAuthorityCodeStr, radix: 10) ?? BigUInt(0)
        if !registrationEntity.issuingAuthorityWhitelist.contains(issuingAuthorityCode) {
            throw "ErrorIssuingAuthority"
        }
    }
}

#Preview {
    RegistrationWaitingView(
        appController: AppController(),
        registrationController: RegistrationController(),
        registrationEntity: RegistrationEntity.sample,
        model: nil,
        isErrorAlertPresent: .constant(false),
        errorMessage: .constant("")
    )
}
