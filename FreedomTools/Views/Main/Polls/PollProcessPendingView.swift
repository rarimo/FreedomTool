import SwiftUI

struct PollProcessPendingView: View {
    @State var stepper = 0;
    
    var body: some View {
        VStack {
            HStack {
                Text("Создание запроса")
                    .font(.custom("RobotoMono-Regular", size: 15))
                Spacer()
                if stepper >= 1 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.second)
                        HStack {
                            Image("Check")
                                .resizable()
                                .frame(width: 16, height: 13)
                            Text("Успешно")
                                .font(.custom("RobotoMono-Medium", size: 14))
                        }
                    }
                    .frame(width: 100, height: 30)
                } else {
                    Text("Загрузка")
                        .font(.custom("RobotoMono-Medium", size: 16))
                        .opacity(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            HStack {
                Text("Анонимизация запроса")
                    .font(.custom("RobotoMono-Regular", size: 15))
                Spacer()
                if stepper >= 2 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.second)
                        HStack {
                            Image("Check")
                                .resizable()
                                .frame(width: 16, height: 13)
                            Text("Успешно")
                                .font(.custom("RobotoMono-Medium", size: 14))
                        }
                    }
                    .frame(width: 100, height: 30)
                } else {
                    Text("Загрузка")
                        .font(.custom("RobotoMono-Medium", size: 16))
                        .opacity(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            HStack {
                Text("Отправка запроса")
                    .font(.custom("RobotoMono-Regular", size: 15))
                Spacer()
                if stepper >= 3 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.second)
                        HStack {
                            Image("Check")
                                .resizable()
                                .frame(width: 16, height: 13)
                            Text("Успешно")
                                .font(.custom("RobotoMono-Medium", size: 14))
                        }
                    }
                    .frame(width: 100, height: 30)
                } else {
                    Text("Загрузка")
                        .font(.custom("RobotoMono-Medium", size: 16))
                        .opacity(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            HStack {
                Text("Завершение")
                    .font(.custom("RobotoMono-Regular", size: 15))
                Spacer()
                if stepper >= 4 {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.second)
                        HStack {
                            Image("Check")
                                .resizable()
                                .frame(width: 16, height: 13)
                            Text("Успешно")
                                .font(.custom("RobotoMono-Medium", size: 14))
                        }
                    }
                    .frame(width: 100, height: 30)
                } else {
                    Text("Загрузка")
                        .font(.custom("RobotoMono-Medium", size: 16))
                        .opacity(0.5)
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                stepper = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                stepper = 2
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                stepper = 3
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                stepper = 4
            }
        }
    }
}

#Preview {
    PollProcessPendingView()
}
