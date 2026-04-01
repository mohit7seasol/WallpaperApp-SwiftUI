//
//  SplashView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 05/03/26.
//

import SwiftUI
import Lottie
import AppTrackingTransparency
import AdSupport

/* struct SplashView: View {

    @AppStorage(SessionKeys.isLanguageDone) var isLanguageDone = false
    @AppStorage(SessionKeys.isOnboardingDone) var isOnboardingDone = false
    @AppStorage(SessionKeys.isOneTimeDone) var isOneTimeDone = true

    @StateObject var vm = SplashViewModel()

    @State var isShowOnboarding = false
    @State var isShowHomeView = false

    var body: some View {

        VStack {
            if isShowHomeView {
                HomeSegmentView()
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

            // Center Icon
            Image("app_icon")
                .resizable()
                .frame(width: 120, height: 120)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            // Bottom Loader
            VStack {
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
} */

struct SplashView: View {

    @AppStorage(SessionKeys.isLanguageDone) var isLanguageDone = false
    @AppStorage(SessionKeys.isOnboardingDone) var isOnboardingDone = false
    @AppStorage(SessionKeys.isOneTimeDone) var isOneTimeDone = true
    @AppStorage("hasRequestedTrackingPermission") var hasRequestedTrackingPermission = false

    @StateObject var vm = SplashViewModel()

    @State var isShowOnboarding = false
    @State var isShowHomeView = false
    @State private var isTrackingPermissionChecked = false

    var body: some View {

        VStack {
            if isShowHomeView {
                HomeSegmentView()
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
        
        // Request tracking permission if needed
        requestTrackingPermissionIfNeeded()
        
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
    
    // MARK: - Tracking Permission Methods
    private func requestTrackingPermissionIfNeeded() {
        // Check if we're on iOS 14 or later
        if #available(iOS 14, *) {
            // Check if already requested permission
            if !hasRequestedTrackingPermission {
                // Show tracking permission request after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    requestTrackingAuthorization()
                }
            }
        } else {
            // For iOS 13 and below, no permission needed
            hasRequestedTrackingPermission = true
            isTrackingPermissionChecked = true
        }
    }
    
    @available(iOS 14, *)
    private func requestTrackingAuthorization() {
        // Check current authorization status
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        switch status {
        case .notDetermined:
            // Request permission
            ATTrackingManager.requestTrackingAuthorization { [self] status in
                DispatchQueue.main.async {
                    handleTrackingStatus(status)
                }
            }
        case .restricted, .denied:
            // Permission denied or restricted
            handleTrackingStatus(status)
        case .authorized:
            // Permission already granted
            handleTrackingStatus(status)
        @unknown default:
            handleTrackingStatus(.denied)
        }
    }
    
    private func handleTrackingStatus(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:
            print("✅ Tracking permission granted")
            // User granted permission - can track
            let advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            print("Advertising ID: \(advertisingId)")
            
            // Update any analytics or ad SDKs
            updateTrackingConsent(true)
            
        case .denied:
            print("❌ Tracking permission denied")
            // User denied permission - don't track
            updateTrackingConsent(false)
            
        case .restricted:
            print("⚠️ Tracking permission restricted")
            // Permission restricted (e.g., parental controls)
            updateTrackingConsent(false)
            
        case .notDetermined:
            print("❓ Tracking permission not determined")
            // Should not happen as we already requested
            
        @unknown default:
            print("Unknown tracking status")
            updateTrackingConsent(false)
        }
        
        // Mark as requested to avoid showing again
        hasRequestedTrackingPermission = true
        isTrackingPermissionChecked = true
    }
    
    private func updateTrackingConsent(_ isAuthorized: Bool) {
        // Update any analytics or ad SDKs with consent status
        
        // Example for Firebase Analytics:
        // Analytics.setUserProperty(isAuthorized ? "granted" : "denied", forName: "tracking_consent")
        
        // Example for Google AdMob:
        if isAuthorized {
            // Enable personalized ads
            print("Personalized ads enabled")
        } else {
            // Disable personalized ads
            print("Non-personalized ads only")
        }
        
        // You can also post a notification for other parts of the app
        NotificationCenter.default.post(
            name: NSNotification.Name("TrackingConsentChanged"),
            object: nil,
            userInfo: ["isAuthorized": isAuthorized]
        )
    }
}

struct SplashContent: View {

    var body: some View {

        ZStack {

            Image("splash_bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Center Icon
            Image("app_icon")
                .resizable()
                .frame(width: 120, height: 120)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            // Bottom Loader
            VStack {
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

#Preview {
    SplashView()
}

