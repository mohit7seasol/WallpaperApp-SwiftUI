//
//  FavoritesManager.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 02/03/26.
//

import Foundation
import Combine

// MARK: - Favorites Manager
class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteWallpapers: [PexelWallpaperData] = []
    
    private let favoritesKey = "favorite_wallpapers"
    
    init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([PexelWallpaperData].self, from: data) {
            favoriteWallpapers = decoded
        }
    }
    
    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteWallpapers) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    func isFavorite(_ wallpaper: PexelWallpaperData) -> Bool {
        return favoriteWallpapers.contains(where: { $0.id == wallpaper.id })
    }
    
    func addToFavorites(_ wallpaper: PexelWallpaperData) {
        if !isFavorite(wallpaper) {
            favoriteWallpapers.append(wallpaper)
            saveFavorites()
            objectWillChange.send()
        }
    }
    
    func removeFromFavorites(_ wallpaper: PexelWallpaperData) {
        favoriteWallpapers.removeAll(where: { $0.id == wallpaper.id })
        saveFavorites()
        objectWillChange.send()
    }
    
    func toggleFavorite(_ wallpaper: PexelWallpaperData) {
        if isFavorite(wallpaper) {
            removeFromFavorites(wallpaper)
        } else {
            addToFavorites(wallpaper)
        }
    }
}
