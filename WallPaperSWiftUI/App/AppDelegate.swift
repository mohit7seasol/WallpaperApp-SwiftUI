//
//  AppDelegate.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 26/02/26.
//

import Foundation
import SwiftUI
import SDWebImage

class AppDelegate: UIResponder, UIApplicationDelegate {
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        SDImageCache.shared.clearMemory()
        SDWebImagePrefetcher.shared.cancelPrefetching()
    }
}
extension AppDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        if #available(iOS 26.0, *) {
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            
            // Transparent background
            appearance.backgroundColor = .clear
            appearance.shadowColor = .clear
            
            // Title color
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
            
            // Back icon
            appearance.setBackIndicatorImage(
                UIImage(systemName: "arrow.left"),
                transitionMaskImage: UIImage(systemName: "arrow.left")
            )
            
            let navBar = UINavigationBar.appearance()
            navBar.prefersLargeTitles = false
            navBar.tintColor = .white
            
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            
        } else {
            UIView.appearance().overrideUserInterfaceStyle = .dark
            
            let barButtonAppearance = UIBarButtonItem.appearance()
            barButtonAppearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
            barButtonAppearance.tintColor = .white
            
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
                UIOffset(horizontal: -1000, vertical: 0),
                for: .default
            )
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            appearance.setBackIndicatorImage(
                UIImage(systemName: "arrow.left"),
                transitionMaskImage: UIImage(systemName: "arrow.left")
            )
            
            let navBar = UINavigationBar.appearance()
            navBar.standardAppearance = appearance
            navBar.compactAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
        }
        
        return true
    }
}
