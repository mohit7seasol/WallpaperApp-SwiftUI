//
//  HomeView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 27/02/26.
//

import SwiftUI
import SDWebImageSwiftUI
import Alamofire
import Combine

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

// Rename using typealias
typealias HomeWallpaperModel = WallpaperModel
typealias HomeData = WallpaperData
typealias HomeThumbs = WallpaperThumbs
typealias HomeMeta = WallpaperMeta

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

// MARK: - Static Category Model
struct StaticCategory: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let searchKeyword: String
}

// MARK: - HomeView
struct HomeView: View {
    @StateObject private var trendingViewModel = TrendingWallpaperViewModel()
    @State private var selectedStaticIndex = 0
    
    let staticCategories = [
        StaticCategory(title: "Cool Wallpaper", imageName: "cool", searchKeyword: "cool"),
        StaticCategory(title: "Landscape", imageName: "landscape", searchKeyword: "landscape"),
        StaticCategory(title: "Forests", imageName: "forest", searchKeyword: "forest")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundBlack
                    .ignoresSafeArea()
                
                // Main Content
                VStack(spacing: 10) {
                    // Top Gradient View - Height 150
                    TopGradientView()
                        .frame(height: 150)
                        .ignoresSafeArea(edges: .top)
                    
                    // Static Categories Section
                    StaticCategoriesSection(
                        categories: staticCategories,
                        selectedIndex: $selectedStaticIndex
                    )
                    .offset(y: -43)
                    .padding(.bottom, -43)
                    
                    // Page Controller
                    PageControl(
                        numberOfPages: staticCategories.count,
                        currentPage: selectedStaticIndex
                    )
                    .padding(.top, 15)
                    
                    // Trending Wallpaper Static Title
                    HStack(spacing: 8) {
                        Image("trend")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                        
                        Text("Trending Wallpaper")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Scrollable Grid Section
                    if trendingViewModel.isLoading && trendingViewModel.wallpapers.isEmpty {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 0) {
                                TrendingWallpapersGrid(
                                    wallpapers: trendingViewModel.wallpapers,
                                    hasMorePages: trendingViewModel.hasMorePages,
                                    isLoading: trendingViewModel.isLoading,
                                    loadMore: {
                                        trendingViewModel.loadMore()
                                    }
                                )
                                .padding(.top, 8)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            trendingViewModel.fetchTrendingWallpapers(loadMore: false)
        }
    }
}
// MARK: - Trending Wallpapers Grid (Scrollable content only)
struct TrendingWallpapersGrid: View {
    let wallpapers: [WallpaperData]
    let hasMorePages: Bool
    let isLoading: Bool
    let loadMore: () -> Void
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(wallpapers.enumerated()), id: \.element.id) { index, wallpaper in
                if let path = wallpaper.path,
                   let url = URL(string: path) {
                    
                    NavigationLink(destination: WallpaperDetailView(wallpaper: wallpaper)) {
                        WebImage(url: url)
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade(duration: 0.5))
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(16)
                            .clipped()
                            .onAppear {
                                // Preload next images when approaching the end
                                if index >= wallpapers.count - 6 {
                                    SDWebImagePrefetcher.shared.prefetchURLs(
                                        wallpapers.suffix(6).compactMap { URL(string: $0.path ?? "") }
                                    )
                                }
                                
                                // Trigger load more when approaching the end
                                if index >= wallpapers.count - 4 && hasMorePages && !isLoading {
                                    loadMore()
                                }
                            }
                    }
                }
            }
            
            // Loading indicator at bottom
            if isLoading && !wallpapers.isEmpty {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Top Gradient View
struct TopGradientView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Wallpaper")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Favorite Icon
                Button(action: {}) {
                    Image("favourite")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
                .padding(.trailing, 8) // Reduced space between buttons
                
                // Settings Icon
                Button(action: {}) {
                    Image("setting_ic")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            Constant.commonBlueGradient
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .offset(x: 150, y: -30)
                )
        )
    }
}

// MARK: - Static Categories Section
struct StaticCategoriesSection: View {
    let categories: [StaticCategory]
    @Binding var selectedIndex: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<categories.count, id: \.self) { index in
                    let category = categories[index]
                    
                    NavigationLink(destination: CategoryDetailView(category: category)) {
                        StaticCategoryCell(
                            category: category,
                            isSelected: selectedIndex == index
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .simultaneousGesture(TapGesture().onEnded {
                        selectedIndex = index
                    })
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Static Category Cell
struct StaticCategoryCell: View {
    let category: StaticCategory
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            // Background Image
            Image(category.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 130, height: 86)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.pageSelected : Color.clear, lineWidth: 3)
                )
            
            // Dark Overlay
            Color.black.opacity(0.3)
                .cornerRadius(20)
            
            // Title
            Text(category.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .frame(width: 110)
        }
        .frame(width: 130, height: 86)
    }
}


// MARK: - Page Control
struct PageControl: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.pageSelected : Color.pageUnselected)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

// MARK: - Trending Wallpapers Section
struct TrendingWallpapersSection: View {
    let wallpapers: [WallpaperData]
    let hasMorePages: Bool
    let isLoading: Bool
    let loadMore: () -> Void
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image("trend")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                
                Text("Trending Wallpaper")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(wallpapers.enumerated()), id: \.element.id) { index, wallpaper in
                    if let path = wallpaper.path,
                       let url = URL(string: path) {
                        
                        NavigationLink(destination: WallpaperDetailView(wallpaper: wallpaper)) {
                            WebImage(url: url)
                                .resizable()
                                .indicator(.activity)
                                .transition(.fade(duration: 0.5))
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(16)
                                .clipped()
                        }
                        .onAppear {
                            // Trigger load more when approaching the end
                            if index >= wallpapers.count - 4 && hasMorePages && !isLoading {
                                print("🔄 Triggering load more at index: \(index)")
                                loadMore()
                            }
                        }
                    }
                }
                
                // Loading indicator at bottom
                if isLoading && !wallpapers.isEmpty {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
// MARK: - Wallpaper Detail View
struct WallpaperDetailView: View {
    let wallpaper: WallpaperData
    
    var body: some View {
        ZStack {
            Color.backgroundBlack
                .ignoresSafeArea()
            
            if let path = wallpaper.path,
               let url = URL(string: path) {
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .scaledToFit()
                    .cornerRadius(16)
                    .padding()
            }
        }
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.white)
        .onDisappear {
            // Clear memory cache when leaving detail view
            SDImageCache.shared.clearMemory()
        }
    }
}

// MARK: - Home Wallpaper ViewModel with NetworkManager
class HomeWallpaperViewModel: ObservableObject {
    @Published var wallpapers: [WallpaperData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private var currentPage = 1
    private var currentQuery = "cool"
    private var currentRequestUrl: String {
        return "https://wallhaven.cc/api/v1/search?q=\(currentQuery)&ratios=portrait&atleast=1080x1920&page=\(currentPage)"
    }
    
    func fetchWallpapers(for query: String) {
        NetworkManager.cancelRequest(url: currentRequestUrl)
        
        isLoading = true
        currentPage = 1
        currentQuery = query
        
        NetworkManager.callWebService(
            url: currentRequestUrl,
            httpMethod: .get,
            params: [:],
            encoding: URLEncoding.default,
            headers: [:]
        ) { [weak self] (response: WallpaperModel) in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.wallpapers = response.data ?? []
                print("✅ Loaded \(self?.wallpapers.count ?? 0) wallpapers for query: \(query)")
            }
        } callbackFailure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.errorMessage = "Failed to load: \(error.localizedDescription)"
                self?.showError = true
                print("❌ Error: \(error.localizedDescription)")
            }
        }
    }
    
    func loadMore() {
        guard !isLoading else { return }
        
        NetworkManager.cancelRequest(url: currentRequestUrl)
        
        currentPage += 1
        
        NetworkManager.callWebService(
            url: currentRequestUrl,
            httpMethod: .get,
            params: [:],
            encoding: URLEncoding.default,
            headers: [:]
        ) { [weak self] (response: WallpaperModel) in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let newWallpapers = response.data {
                    self?.wallpapers.append(contentsOf: newWallpapers)
                    print("✅ Loaded \(newWallpapers.count) more wallpapers")
                }
            }
        } callbackFailure: { [weak self] error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.errorMessage = "Failed to load more: \(error.localizedDescription)"
                self?.showError = true
            }
        }
    }
    
    func refreshWallpapers() {
        wallpapers.removeAll()
        fetchWallpapers(for: currentQuery)
    }
    
    deinit {
        NetworkManager.cancelRequest(url: currentRequestUrl)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
