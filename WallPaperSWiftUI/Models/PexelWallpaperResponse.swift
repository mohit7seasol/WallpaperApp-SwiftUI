//
//  PexelWallpaperResponse.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 28/02/26.
//

import Foundation

struct PexelWallpaperResponse: Codable {
    let total: Int
    let page: Int
    let limit: Int
    let totalPages: Int
    let data: [PexelWallpaperData]
}

struct PexelWallpaperData: Codable, Identifiable {
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
    let src: PexelWallpaperSrc
    let createdAt: String?
    let updatedAt: String?
    let v: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case pexelsId
        case width
        case height
        case url
        case alt
        case photographer
        case photographerId
        case photographerUrl
        case avgColor
        case liked
        case category
        case src
        case createdAt
        case updatedAt
        case v = "__v"
    }
}

struct PexelWallpaperSrc: Codable {
    let original: String
    let large2x: String
    let large: String
    let medium: String
    let small: String
    let portrait: String
    let landscape: String
    let tiny: String
}
