//
//  SplashView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 05/03/26.
//

import SwiftUI
import Lottie

struct SplashView: View {

    @AppStorage(SessionKeys.isLanguageDone) var isLanguageDone = false
    @AppStorage(SessionKeys.isOnboardingDone) var isOnboardingDone = false
    @AppStorage(SessionKeys.isOneTimeDone) var isOneTimeDone = true

    @StateObject var vm = SplashViewModel()

    @State var isShowOnboarding = false
    @State var isShowHomeView = false

    var body: some View {

        VStack {
            if isShowHomeView {
                HomeView()
            } else {
                SplashContent()
            }
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $isShowOnboarding) {
            OnBoardingView()
        }
        .onAppear {
            handleStartupFlow()
        }
    }

    private func handleStartupFlow() {

        vm.fetchSplashData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {

            if !isLanguageDone || !isOnboardingDone {

                isShowOnboarding = true
                isOneTimeDone = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isShowHomeView = true
                }

            } else {

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isShowHomeView = true
                }
            }
        }
    }
}

struct SplashContent: View {

    var body: some View {

        ZStack {

            Image("splash_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {

                Spacer()

                Image("app_icon")
                    .resizable()
                    .frame(width: 120, height: 120)

                Spacer()

                MyLottieView(
                    animationFileName: "Loader",
                    loopMode: .loop
                )
                .frame(width: 100, height: 100)
                .padding(.bottom, 60)

            }
        }
    }
}
