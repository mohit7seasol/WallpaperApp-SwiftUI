//
//  LanguageView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 03/03/26.
//

import Foundation
import SwiftUI
import Lottie

struct LanguageView: View {
    
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    @Environment(\.presentationMode) var presentationMode
    @AppStorage(SessionKeys.isLanguageDone) var isLanguageDone = false
    @StateObject var vm = LanguageViewModel()
    
    private var isIpad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var cellHeight: CGFloat {
        isIpad ? 100 : 60
    }
    
    private var iconSize: CGFloat {
        isIpad ? 60 : 40
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#0B0C1E")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: Top Section
                HStack(alignment: .top) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        
                        Text("Choose Language")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Select your preferred app\nlanguage")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#9398C8"))
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    MyLottieView(animationFileName: "translation",
                                 loopMode: .loop)
                        .frame(width: 132, height: 132)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // MARK: Continue Button
                Button {
                    language = vm.selectedLanguage ?? .English
                    if !isLanguageDone {
                        isLanguageDone = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    Text("Continue")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(
                            Color(hex: "#5A5ED9")
                                .opacity(0.3)
                        )
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // MARK: Language List
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        
                        ForEach(languages, id: \.id) { item in
                            
                            LanguageRow(
                                item: item,
                                isSelected: vm.selectedLanguage == item.languageCode,
                                cellHeight: cellHeight,
                                iconSize: iconSize
                            )
                            .onTapGesture {
                                vm.selectedLanguage = item.languageCode
                            }
                        }
                    }
                    .padding(.horizontal, 15) // 15 left & right
                    .padding(.top, 25)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            vm.selectedLanguage = languages.first?.languageCode // Default first selected
        }
    }
}
struct LanguageRow: View {
    
    let item: AppLanguage
    let isSelected: Bool
    let cellHeight: CGFloat
    let iconSize: CGFloat
    
    var body: some View {
        HStack(spacing: 15) {
            
            item.image
                .resizable()
                .scaledToFill()
                .frame(width: iconSize, height: iconSize)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text("\(item.englishName) (\(item.LocalName))")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            if isSelected {
                Image("selected_language")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 22)
            }
        }
        .padding(.horizontal, 18)
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
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        )
    }
}
