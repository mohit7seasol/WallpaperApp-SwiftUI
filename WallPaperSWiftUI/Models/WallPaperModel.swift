//
//  WallPaperModel.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 26/02/26.
//

import Foundation

// MARK: - Wallpaper Model
struct Wallpaper: Identifiable, Codable {
    let id = UUID()
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url
    }
}

// Since the API returns an array of strings directly
typealias WallpaperResponse = [String]
