//
//  RegistrationWaitingView.swift
//  FreedomTools
//
//  Created by Ivan Lele on 02.03.2024.
//

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
                        
                        print("Got an old user: \(userID)")
                    } else {
                        do {
                           try validateModel()
                        } catch let error {
                            self.registerHandledError(error)
                            
                            return
                        }
                        
                        try await appController.newUser(model!)
                        
                        print("Creating new user, userID: \(userID)")
                    }
                }
                
                waitingStepper += 1
                
                if appController.user!.requestedIn.contains(registrationEntity.address) {
                    print("Found reqistrationRequest")
                    waitingStepper += 2
                } else {
                    print("Waiting for user identity to finalize")
                    var isFinalized = false
                    while !isFinalized {
                        print("Check user finalization...")
                        isFinalized = try appController.isUserFinalized()
                        // sleep 10 second
                        try await Task.sleep(nanoseconds: 10000000000)
                    }
                    
                    print("user identity was finalized")
                    
                    waitingStepper += 1
                    
                    print("registering new user")
                    do {
                        try await appController.register(address: registrationEntity.address)
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
                    
                    print("New user was registered")
                    
                    var updatedUser = appController.user!
                    updatedUser.requestedIn.append(registrationEntity.address)
                    
                    waitingStepper += 1
                        
                    try! appController.updateUser(updatedUser)
                    
                    print("User local base updated")
                }
                
                print("Waiting for the registration tx to execute")
                
                var isReqistered = false
                while !isReqistered {
                    print("Check user registration...")
                    isReqistered = try await appController.isUserRegistered(
                        address: registrationEntity.address
                    )
                    // sleep 10 second
                    try await Task.sleep(nanoseconds: 10000000000)
                }
                
                print("The registration tx was executed")
                
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
