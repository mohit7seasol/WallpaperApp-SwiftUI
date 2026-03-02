//
//  HomeModel.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 27/02/26.
//

 
import Foundation

// MARK: - Original Models (with typealias for renaming)
struct WallpaperModel: Codable {
    let data: [WallpaperData]?
    let meta: WallpaperMeta?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
        case meta = "meta"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([WallpaperData].self, forKey: .data)
        meta = try values.decodeIfPresent(WallpaperMeta.self, forKey: .meta)
    }
}

struct WallpaperData: Codable {
    let id: String?
    let url: String?
    let short_url: String?
    let views: Int?
    let favorites: Int?
    let source: String?
    let purity: String?
    let category: String?
    let dimension_x: Int?
    let dimension_y: Int?
    let resolution: String?
    let ratio: String?
    let file_size: Int?
    let file_type: String?
    let created_at: String?
    let colors: [String]?
    let path: String?
    let thumbs: WallpaperThumbs?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "url"
        case short_url = "short_url"
        case views = "views"
        case favorites = "favorites"
        case source = "source"
        case purity = "purity"
        case category = "category"
        case dimension_x = "dimension_x"
        case dimension_y = "dimension_y"
        case resolution = "resolution"
        case ratio = "ratio"
        case file_size = "file_size"
        case file_type = "file_type"
        case created_at = "created_at"
        case colors = "colors"
        case path = "path"
        case thumbs = "thumbs"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        url = try values.decodeIfPresent(String.self, forKey: .url)
        short_url = try values.decodeIfPresent(String.self, forKey: .short_url)
        views = try values.decodeIfPresent(Int.self, forKey: .views)
        favorites = try values.decodeIfPresent(Int.self, forKey: .favorites)
        source = try values.decodeIfPresent(String.self, forKey: .source)
        purity = try values.decodeIfPresent(String.self, forKey: .purity)
        category = try values.decodeIfPresent(String.self, forKey: .category)
        dimension_x = try values.decodeIfPresent(Int.self, forKey: .dimension_x)
        dimension_y = try values.decodeIfPresent(Int.self, forKey: .dimension_y)
        resolution = try values.decodeIfPresent(String.self, forKey: .resolution)
        ratio = try values.decodeIfPresent(String.self, forKey: .ratio)
        file_size = try values.decodeIfPresent(Int.self, forKey: .file_size)
        file_type = try values.decodeIfPresent(String.self, forKey: .file_type)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        colors = try values.decodeIfPresent([String].self, forKey: .colors)
        path = try values.decodeIfPresent(String.self, forKey: .path)
        thumbs = try values.decodeIfPresent(WallpaperThumbs.self, forKey: .thumbs)
    }
}

struct WallpaperThumbs: Codable {
    let large: String?
    let original: String?
    let small: String?
    
    enum CodingKeys: String, CodingKey {
        case large = "large"
        case original = "original"
        case small = "small"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        large = try values.decodeIfPresent(String.self, forKey: .large)
        original = try values.decodeIfPresent(String.self, forKey: .original)
        small = try values.decodeIfPresent(String.self, forKey: .small)
    }
}

struct WallpaperMeta: Codable {
    let current_page: Int?
    let last_page: Int?
    let per_page: Int?
    let total: Int?
    let query: String?
    let seed: String?
    
    enum CodingKeys: String, CodingKey {
        case current_page = "current_page"
        case last_page = "last_page"
        case per_page = "per_page"
        case total = "total"
        case query = "query"
        case seed = "seed"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        current_page = try values.decodeIfPresent(Int.self, forKey: .current_page)
        last_page = try values.decodeIfPresent(Int.self, forKey: .last_page)
        per_page = try values.decodeIfPresent(Int.self, forKey: .per_page)
        total = try values.decodeIfPresent(Int.self, forKey: .total)
        query = try values.decodeIfPresent(String.self, forKey: .query)
        seed = try values.decodeIfPresent(String.self, forKey: .seed)
    }
}
