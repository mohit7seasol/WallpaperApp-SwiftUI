//
//  WallpaperViewModel.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 26/02/26.
//

import Foundation
import SwiftUI
import Combine
import Alamofire

// MARK: - Wallpaper ViewModel
class WallpaperViewModel: ObservableObject {
    @Published var wallpapers: [Wallpaper] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private var currentRequestUrl = "https://d2is1ss4hhk4uk.cloudfront.net/iphonewallpaper.json"
    
    func fetchWallpapers() {
        guard !isLoading else { return }
        
        // Update UI on main thread
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // Cancel any existing request to the same URL
        NetworkManager.cancelRequest(url: currentRequestUrl)
        
        // Using NetworkManager to call the web service
        NetworkManager.callWebService(
            url: currentRequestUrl,
            httpMethod: .get,
            params: [:],
            encoding: URLEncoding.default,
            headers: [:] // No authorization needed for this public endpoint
        ) { [weak self] (response: [String]) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.wallpapers = response.map { Wallpaper(url: $0) }
                print("✅ Successfully loaded \(response.count) wallpapers")
            }
        } callbackFailure: { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to load wallpapers: \(error.localizedDescription)"
                self.showError = true
                print("❌ Error fetching wallpapers: \(error.localizedDescription)")
            }
        }
    }
    
    func refreshWallpapers() {
        wallpapers.removeAll()
        fetchWallpapers()
    }
    
    deinit {
        // Cancel any ongoing request when the ViewModel is deallocated
        NetworkManager.cancelRequest(url: currentRequestUrl)
    }
}
