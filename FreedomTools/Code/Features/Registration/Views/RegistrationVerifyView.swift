import SwiftUI

struct RegistrationVerifyView: View {
    let registrationEntity: RegistrationEntity
    
    let onVerify: () -> Void
    
    var body: some View {
        VStack {
            RegistrationDetailsHeaderView(registrationEntity: registrationEntity)
            Spacer()
                .frame(height: 30)
            HStack {
                Text("VotingCriteria")
                    .font(.custom("RobotoSlab-Bold", size: 14))
                    .opacity(0.5)
                Spacer()
            }
            .padding(.horizontal)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .opacity(0.05)
                HStack {
                    Text("Status")
                        .font(.custom("RobotoMono-Regular", size: 16))
                        .padding(.horizontal)
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.betterYellow)
                        HStack {
                            Text("VerificationRequired")
                                .font(.custom("RobotoMono-Medium", size: 14))
                                .foregroundStyle(.black)
                        }
                    }
                    .frame(width: 200, height: 30)
                    .padding(.horizontal)
                }
            }
            .frame(width: 365, height: 50)
            Spacer()
                .frame(height: 15)
            HStack {
                Image("YellowCircle")
                    .resizable()
                    .frame(width: 20.83, height: 21.67)
                Spacer()
                    .frame(width: 15)
                Text("Are18YearsOld")
                    .font(.custom("RobotoSlab-Regular", size: 14))
                Spacer()
            }
            .padding(.horizontal)
            if !registrationEntity.issuingAuthorityWhitelist.isEmpty {
                HStack {
                    Image("YellowCircle")
                        .resizable()
                        .frame(width: 20.83, height: 21.67)
                    Spacer()
                        .frame(width: 15)
                    Text("CitizenOf")
                        .font(.custom("RobotoSlab-Regular", size: 14))
                    ForEach(registrationEntity.issuingAuthorityWhitelist, id: \.self) { issuingAuthority in
                        Text(issuingAuthority.description.reversedIntPreImage())
                            .font(.custom("RobotoSlab-Regular", size: 14))
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            Spacer()
                .frame(height: 40)
            Text("VerifyTip")
                .font(.custom("RobotoMono-Regular", size: 14))
                .opacity(0.5)
                .padding(.horizontal)
            Spacer()
            Button(action: onVerify) {
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.black)
                    HStack {
                        Image("Participate")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Authorize")
                            .font(.custom("RobotoMono-Semibold", size: 15))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 325, height: 55)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    RegistrationVerifyView(registrationEntity: RegistrationEntity.sample) {}
}
