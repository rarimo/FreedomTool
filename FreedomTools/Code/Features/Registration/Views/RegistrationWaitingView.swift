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
    @EnvironmentObject var appViewModel: AppView.ViewModel
    
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
                .font(.custom("Inter-Semibold", size: 20))
                .multilineTextAlignment(.center)
                .frame(width: 300, height: 60)
            if !isDone {
                Text("PleaseWaitSub")
                    .font(.custom("Inter-Regular", size: 15))
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
                        .font(.custom("Inter-Bold", size: 14))
                }
                .buttonStyle(.plain)
            } else {
                VStack {
                    Divider()
                    (
                        Text("Remember")
                            .font(.custom("Inter-Medium", size: 11)) +
                        Text("RememberHint")
                            .font(.custom("Inter-Regular", size: 11))
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
        .onAppear {
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" {
                self.wait()
            }
        }
        .onDisappear {
            checkingTask.cancel()
        }
    }
    
    func wait() {
        let task = Task { @MainActor in
            do {
                if appViewModel.user == nil {
                    let userID = try model!.getIdentidier()
                    
                    if try UserStorage.isUserExist(id: userID) {
                        try appViewModel.loadUser(userId: userID)
                    } else {
                        try validateModel()
                        
                        try await appViewModel.newUser(model!)
                    }
                }
                
                waitingStepper += 1
                
                if appViewModel.user!.requestedIn.contains(registrationEntity.address) {
                    waitingStepper += 2
                } else {
                    while true {
                        let isFinalized = try appViewModel.isUserFinalized()
                        if isFinalized {
                            break
                        }
                        
                        // sleep 10 second
                        try await Task.sleep(nanoseconds: 10_000_000_000)
                    }
                    
                    waitingStepper += 1
                    
                    let txHash = try await appViewModel.register(address: registrationEntity.address)
                    
                    print("register tx hash: \(txHash)")
                    
                    var updatedUser = appViewModel.user!
                    updatedUser.requestedIn.append(registrationEntity.address)
                    
                    waitingStepper += 1
                        
                    try! appViewModel.updateUser(updatedUser)
                }
                
                while true {
                    let isReqistered = try await appViewModel.isUserRegistered(
                        address: registrationEntity.address
                    )
                    if isReqistered {
                        break
                    }
                    
                    // sleep 10 second
                    try await Task.sleep(nanoseconds: 10_000_000_000)
                }
                
                waitingStepper += 1
                self.isDone = true
            } catch let error {
                print("Waiting error: \(error)")
                
                self.registerHandledError(error)
            }
        }
        
        self.checkingTask = task
    }
    
    func registerHandledError(_ error: Error) {
        if error.isCancelled {
            return
        }
        
        var newErrorMessage = "ErrorServicesOutOfWork"
        
        let errorStr = "\(error)"
        if errorStr.starts(with: "Error") {
            newErrorMessage = errorStr
        }
        
        if errorStr.contains("user already registered") {
            newErrorMessage = "ErrorYouAlredySigned"
        }
        
        if errorStr.contains("no non-revoked credentials found") {
            newErrorMessage = "ErrorIdentityRevoked"
        }
        
        errorMessage = newErrorMessage
        isErrorAlertPresent = true
        
        registrationController.currentStep = .sign
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
        registrationController: RegistrationController(),
        registrationEntity: RegistrationEntity.sample,
        model: nil,
        isErrorAlertPresent: .constant(false),
        errorMessage: .constant("")
    )
    .environmentObject(AppView.ViewModel())
}
