//
//  OnBoardingView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 03/03/26.
//

// O1- All Wallpaper You Need
// O2 - High Quality Wallpaper Download
// O3 - Upgrade Your Lock Screen
// O4 - Set Your Favorite Live Wallpaper

import SwiftUI

struct OnBoardingView: View {
    
    @State private var currentIndex = 0
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var buttonSize: CGFloat {
        isIpad ? 80 : 50
    }
    
    private var pageControlWidth: CGFloat {
        isIpad ? 150 : 100
    }
    
    private let pages: [OnboardingItem] = [
        OnboardingItem(
            background: "on1",
            centerImage: "on1_1",
            title: "All Wallpaper You Need"
        ),
        OnboardingItem(
            background: "on2",
            centerImage: "on2_1",
            title: "High Quality Wallpaper Download"
        ),
        OnboardingItem(
            background: "on3",
            centerImage: "on3_1",
            title: "Upgrade Your Lock Screen"
        ),
        OnboardingItem(
            background: "on4",
            centerImage: "on4_1",
            title: "Set Your Favorite Live Wallpaper"
        )
    ]
    
    var body: some View {
        ZStack {
            
            // MARK: Background
            Image(pages[currentIndex].background)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // MARK: Dark Overlay
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack {
                
                Spacer()
                
                // MARK: Center Image
                Image(pages[currentIndex].centerImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: isIpad ? 450 : 280)
                    .padding(.bottom, 30)
                
                // MARK: Title
                Text(pages[currentIndex].title)
                    .font(.custom("Oxanium-SemiBold", size: 32))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                // MARK: Bottom Controls
                HStack {
                    
                    // Previous Button (Hidden on First Screen)
                    if currentIndex != 0 {
                        Button {
                            withAnimation {
                                currentIndex -= 1
                            }
                        } label: {
                            Image("on_previous")
                                .resizable()
                                .scaledToFit()
                                .frame(width: buttonSize, height: buttonSize)
                        }
                    } else {
                        // Keep spacing alignment
                        Spacer()
                            .frame(width: buttonSize, height: buttonSize)
                    }
                    
                    Spacer()
                    
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentIndex ? Color.white : Color.white.opacity(0.4))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .frame(width: pageControlWidth)
                    
                    Spacer()
                    
                    // Next / Done Button
                    Button {
                        if currentIndex < pages.count - 1 {
                            withAnimation {
                                currentIndex += 1
                            }
                        } else {
                            // Done Action
                            print("Onboarding Finished")
                        }
                    } label: {
                        Image(currentIndex == pages.count - 1 ? "on_done" : "on_next")
                            .resizable()
                            .scaledToFit()
                            .frame(width: buttonSize, height: buttonSize)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, isIpad ? 60 : 40)
            }
        }
    }
}

// MARK: - Model

struct OnboardingItem {
    let background: String
    let centerImage: String
    let title: String
}

#Preview {
    OnBoardingView()
}
