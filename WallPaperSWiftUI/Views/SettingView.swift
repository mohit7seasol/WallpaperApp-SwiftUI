//
//  SettingView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 03/03/26.
//

import SwiftUI
import StoreKit

struct SettingView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var showingRateDialog = false
    @State private var navigateToLanguage = false
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var cellHeight: CGFloat {
        isIpad ? 80 : 60
    }
    
    private var iconSize: CGFloat {
        isIpad ? 50 : 40
    }
    
    // MARK: - Settings Data
    let settingsItems: [SettingItem] = [
        SettingItem(icon: "language", title: "Language", action: .language),
        SettingItem(icon: "privacypolicy", title: "Privacy Policy", action: .url("privacyPolicy")),
        SettingItem(icon: "aboutus", title: "About Us", action: .url("aboutUs")),
        SettingItem(icon: "termsofuse", title: "Terms Of Use", action: .url("termsOfUse")),
        SettingItem(icon: "rateus", title: "Rate App", action: .rate),
        SettingItem(icon: "inviteyourfriends", title: "Invite Your Friends", action: .url("shareApp")),
        SettingItem(icon: "eula", title: "EULA", action: .url("eula"))
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: - Background
            Color("appTheme")
                .ignoresSafeArea()
            
            // MARK: - Top Banner
            Image("setting_top")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 260)
                .frame(maxWidth: .infinity)
                .clipped()
                .ignoresSafeArea(edges: .top)
            
            // MARK: - Settings List
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    ForEach(settingsItems) { item in
                        SettingCell(
                            item: item,
                            showingRateDialog: $showingRateDialog,
                            navigateToLanguage: $navigateToLanguage,
                            cellHeight: cellHeight,
                            iconSize: iconSize
                        )
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 180)
                .padding(.bottom, 40)
            }
            
            // MARK: - Custom Navigation Bar
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Settings".localized(language))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, safeAreaTop())
                
                Spacer()
            }
            
            // ✅ Hidden NavigationLink (No UI change)
            NavigationLink(
                destination: LanguageView(),
                isActive: $navigateToLanguage
            ) {
                EmptyView()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Safe Area Fix
    private func safeAreaTop() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.top ?? 0
    }
}

// MARK: - Setting Item Model

struct SettingItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let action: SettingAction
}

enum SettingAction {
    case language
    case url(String)
    case rate
}

// MARK: - Setting Cell

struct SettingCell: View {
    
    let item: SettingItem
    @Binding var showingRateDialog: Bool
    @Binding var navigateToLanguage: Bool
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    let cellHeight: CGFloat
    let iconSize: CGFloat
    
    var body: some View {
        Button(action: {
            handleTap()
        }) {
            HStack(spacing: 15) {
                
                Image(item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                
                Text(item.title.localized(language))
                    .font(.system(size: iconSize == 50 ? 22 : 17, weight: .medium))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: cellHeight)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.black.opacity(0.45))
                    
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.35),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Rate App",
               isPresented: $showingRateDialog) {
            Button("Rate Now") {
                rateApp()
            }
            Button("Later", role: .cancel) { }
        } message: {
            Text("Please rate our app in the App Store")
        }
    }
    
    private func handleTap() {
        switch item.action {
        case .language:
            navigateToLanguage = true
            
        case .url(let linkName):
            handleURLNavigation(linkName: linkName)
            
        case .rate:
            showingRateDialog = true
        }
    }
    
    private func handleURLNavigation(linkName: String) {
        var urlString = ""
        
        switch linkName {
        case "privacyPolicy":
            urlString = "https://yourwebsite.com/privacy"
        case "aboutUs":
            urlString = "https://yourwebsite.com/about"
        case "termsOfUse":
            urlString = "https://yourwebsite.com/terms"
        case "eula":
            urlString = "https://yourwebsite.com/eula"
        case "shareApp":
            shareApp()
            return
        default:
            break
        }
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareApp() {
        let appURL = "https://apps.apple.com/app/id123456789"
        
        let activityVC = UIActivityViewController(
            activityItems: ["Check out this amazing app!", URL(string: appURL)!],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}

// MARK: - Preview

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingView()
        }
    }
}
