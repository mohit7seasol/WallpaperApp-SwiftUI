//
//  FavoritesManager.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 02/03/26.
//

import Foundation
import Combine
import SwiftUI

// MARK: - Favorites Manager
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteWallpapers: [PexelWallpaperData] = []
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    private let favoritesKey = "favorite_wallpapers"
    private var toastWorkItem: DispatchWorkItem?
    
    private init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else { return }
        
        do {
            let decoded = try JSONDecoder().decode([PexelWallpaperData].self, from: data)
            DispatchQueue.main.async {
                self.favoriteWallpapers = decoded
            }
        } catch {
            print("Failed to load favorites: \(error.localizedDescription)")
        }
    }
    
    func saveFavorites() {
        do {
            let encoded = try JSONEncoder().encode(favoriteWallpapers)
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        } catch {
            print("Failed to save favorites: \(error.localizedDescription)")
        }
    }
    
    func isFavorite(_ wallpaper: PexelWallpaperData) -> Bool {
        return favoriteWallpapers.contains(where: { $0.id == wallpaper.id })
    }
    
    func addToFavorites(_ wallpaper: PexelWallpaperData) {
        if !isFavorite(wallpaper) {
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    self.favoriteWallpapers.append(wallpaper)
                    self.saveFavorites()
                    self.objectWillChange.send()
                    self.showToastMessage("Added to favorites".localized(self.language))
                }
            }
        }
    }
    
    func removeFromFavorites(_ wallpaper: PexelWallpaperData) {
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                self.favoriteWallpapers.removeAll(where: { $0.id == wallpaper.id })
                self.saveFavorites()
                self.objectWillChange.send()
                self.showToastMessage("Removed from favorites".localized(self.language))
            }
        }
    }
    
    func toggleFavorite(_ wallpaper: PexelWallpaperData) {
        if isFavorite(wallpaper) {
            removeFromFavorites(wallpaper)
        } else {
            addToFavorites(wallpaper)
        }
    }
    
    private func showToastMessage(_ message: String) {
        // Cancel previous toast
        toastWorkItem?.cancel()
        
        // Set new toast message
        toastMessage = message
        withAnimation(.easeInOut) {
            showToast = true
        }
        
        // Create new work item to hide toast
        let workItem = DispatchWorkItem { [weak self] in
            withAnimation(.easeInOut) {
                self?.showToast = false
            }
        }
        toastWorkItem = workItem
        
        // Schedule hiding toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
    
    func clearAllFavorites() {
        DispatchQueue.main.async {
            withAnimation {
                self.favoriteWallpapers.removeAll()
                self.saveFavorites()
                self.objectWillChange.send()
                self.showToastMessage("All favorites cleared".localized(self.language))
            }
        }
    }
}
