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
