import SwiftUI
import NFCPassportReader

struct OnboardConfirmDataView: View {
    @ObservedObject var onboardController: OnboardController
    
    let passportModel: NFCPassportModel
    
    @State var isConfirmed = false
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .opacity(0.03)
                    HStack {
                        VStack {
                            HStack {
                                Text("\(passportModel.firstName) \(passportModel.lastName)")
                                    .font(.custom("RobotoMono-Medium", size: 17))
                                Spacer()
                            }
                            HStack {
                                Text("\(passportModel.gender == "M" ? "Male" : "Female")")
                                    .font(.custom("RobotoMono-Regular", size: 15))
                                    .opacity(0.5)
                                Spacer()
                            }
                        }
                        Spacer()
                        Image(uiImage: passportModel.passportImage ?? UIImage(named: "ManFace")!)
                            .resizable()
                            .frame(width: 50, height: 65)
                    }
                    .padding(.horizontal)
                }
                .frame(width: 350, height: 90)
                .padding(.bottom)
                .padding(.bottom)
                VStack {
                    HStack {
                        Text("Nationality")
                            .font(.custom("RobotoMono-Regular", size: 15))
                            .opacity(0.5)
                        Spacer()
                        Text(passportModel.issuingAuthority)
                            .font(.custom("RobotoMono-Medium", size: 15))
                    }
                    .padding(.bottom)
                    HStack {
                        Text("DocumentnNumber")
                            .font(.custom("RobotoMono-Regular", size: 15))
                            .opacity(0.5)
                        Spacer()
                        Text(passportModel.documentNumber)
                            .font(.custom("RobotoMono-Medium", size: 15))
                    }
                    .padding(.bottom)
                    HStack {
                        Text("DateOfExpiry")
                            .font(.custom("RobotoMono-Regular", size: 15))
                            .opacity(0.5)
                        Spacer()
                        Text(passportModel.documentExpiryDate.parsableDateToPretty())
                            .font(.custom("RobotoMono-Medium", size: 15))
                    }
                    .padding(.bottom)
                    HStack {
                        Text("DateOfBirth")
                            .font(.custom("RobotoMono-Regular", size: 15))
                            .opacity(0.5)
                        Spacer()
                        Text(passportModel.dateOfBirth.parsableDateToPretty())
                            .font(.custom("RobotoMono-Medium", size: 15))
                    }
                    .padding(.bottom)
                }
                .padding(.horizontal)
                .padding(.horizontal)
                Spacer()
                SubmitButtonView("Next") {
                    isConfirmed = true
                }
            }
            if isConfirmed {
                Color.white
                    .ignoresSafeArea()
                OnboardFakeGenView(onboardController: onboardController)
            }
        }
    }
}

#Preview {
    OnboardConfirmDataView(onboardController: OnboardController(), passportModel: NFCPassportModel())
}
