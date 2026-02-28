//
//  NewWallpaperResponse.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 28/02/26.
//

struct NewWallpaperResponse: Codable {
    let total: Int
    let page: Int
    let limit: Int
    let totalPages: Int
    let data: [NewWallpaperData]
}

struct NewWallpaperData: Codable, Identifiable {
    let id: String
    let pexelsId: Int
    let width: Int
    let height: Int
    let url: String
    let alt: String
    let photographer: String
    let photographerId: Int
    let photographerUrl: String
    let avgColor: String
    let liked: Bool
    let category: String
    let src: NewWallpaperSrc
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pexelsId, width, height, url, alt, photographer, photographerId, photographerUrl, avgColor, liked, category, src
    }
}

struct NewWallpaperSrc: Codable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}
