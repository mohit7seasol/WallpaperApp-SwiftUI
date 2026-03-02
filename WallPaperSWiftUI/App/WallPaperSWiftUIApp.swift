//
//  WallPaperSWiftUIApp.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 26/02/26.
//

import SwiftUI
import Toasts

@main
struct WallPaperSWiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var favoritesManager = FavoritesManager.shared
    
    init() {
        UIView.appearance().overrideUserInterfaceStyle = .dark
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .installToast(position: .bottom)
                .environmentObject(favoritesManager)
        }
    }
}
