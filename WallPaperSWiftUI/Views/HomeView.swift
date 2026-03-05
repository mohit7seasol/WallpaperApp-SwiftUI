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
import ACarousel

// MARK: - Static Category Model
struct StaticCategory: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let searchKeyword: String
    
    init(title: String, searchKeyword: String) {
        self.title = title
        self.searchKeyword = searchKeyword
        // Create image name from title (lowercase, no spaces)
        self.imageName = title.lowercased().replacingOccurrences(of: " ", with: "")
    }
}

// MARK: - HomeView
struct HomeView: View {
    @StateObject private var trendingViewModel = TrendingWallpaperViewModel()
    @State private var selectedStaticIndex = 0
    @StateObject private var favoritesManager = FavoritesManager.shared
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    // Get screen width for cell calculation
    let screenWidth = UIScreen.main.bounds.width
    
    // Calculate cell width based on device
    var cellWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return (screenWidth - 64) / 4 // iPad: 4 columns with padding
        } else {
            return (screenWidth - 48) / 2 // iPhone: 2 columns with padding
        }
    }
    
    // Cell height based on device
    var cellHeight: CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? 250 : 220
    }
    
    let staticCategories: [StaticCategory] = [
        StaticCategory(title: "Cool Wallpaper", searchKeyword: "coolwallpaper"),
        StaticCategory(title: "Landscape", searchKeyword: "landscape"),
        StaticCategory(title: "Forests", searchKeyword: "forests"),
        StaticCategory(title: "Garden", searchKeyword: "garden"),
        StaticCategory(title: "Hills", searchKeyword: "hills"),
        StaticCategory(title: "Wildlife", searchKeyword: "wildlife"),
        StaticCategory(title: "Beaches", searchKeyword: "beaches"),
        StaticCategory(title: "Birds", searchKeyword: "birds"),
        StaticCategory(title: "Lord", searchKeyword: "lord"),
        StaticCategory(title: "Clouds", searchKeyword: "clouds"),
        StaticCategory(title: "Architecture", searchKeyword: "architecture"),
        StaticCategory(title: "Bikes", searchKeyword: "bikes"),
        StaticCategory(title: "Minimalist", searchKeyword: "minimalist"),
        StaticCategory(title: "Galaxy", searchKeyword: "galaxy"),
        StaticCategory(title: "Planets", searchKeyword: "planets"),
        StaticCategory(title: "Magic", searchKeyword: "magic"),
        StaticCategory(title: "Cartoons", searchKeyword: "cartoons"),
        StaticCategory(title: "Romance", searchKeyword: "romance"),
        StaticCategory(title: "eSports", searchKeyword: "esports"),
        StaticCategory(title: "Digital Art", searchKeyword: "digitalart"),
        StaticCategory(title: "Festival", searchKeyword: "festival"),
        StaticCategory(title: "Cute", searchKeyword: "cute"),
        StaticCategory(title: "Rain", searchKeyword: "rain"),
        StaticCategory(title: "Plant", searchKeyword: "plant"),
        StaticCategory(title: "3D Wallpaper", searchKeyword: "wallpaper3d"),
        StaticCategory(title: "4K Wallpaper", searchKeyword: "wallpaper4k"),
        StaticCategory(title: "8K Wallpaper", searchKeyword: "wallpaper8k"),
        StaticCategory(title: "32K Wallpaper", searchKeyword: "wallpaper32k"),
        StaticCategory(title: "Live Wallpaper", searchKeyword: "livewallpaper")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBgColor
                    .ignoresSafeArea()
                
                // Main Content
                VStack(spacing: 10) {
                    // Top Gradient View - Height 150
                    TopGradientView()
                        .frame(height: 180)
                        .ignoresSafeArea(edges: .top)
                    
                    // Static Categories Section
                    StaticCategoriesSection(
                        categories: staticCategories,
                        selectedIndex: $selectedStaticIndex
                    )
                    .offset(y: -114)
                    .padding(.bottom, -43)
                    
                    // Page Control
                    PageControl(
                        numberOfPages: staticCategories.count,
                        currentPage: selectedStaticIndex
                    )
                    .padding(.top, -50)
                    
                    // Live Wallpaper Banner
                    WallpaperBannerView()
                        .padding(.horizontal, 15)
                        .padding(.top, -30)
                    
                    // Trending Wallpaper Static Title
                    HStack(spacing: 8) {
                        Image("trend")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
                        Text("Trending Wallpaper")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 0)
                    
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
                                    },
                                    cellWidth: cellWidth,
                                    cellHeight: cellHeight
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
        .toast(isShowing: $favoritesManager.showToast, message: favoritesManager.toastMessage)
    }
}

// MARK: - Trending Wallpapers Grid
struct TrendingWallpapersGrid: View {
    let wallpapers: [PexelWallpaperData]
    let hasMorePages: Bool
    let isLoading: Bool
    let loadMore: () -> Void
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    
    @StateObject private var favoritesManager = FavoritesManager.shared
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(wallpapers.enumerated()), id: \.element.id) { index, wallpaper in
                ZStack(alignment: .bottomTrailing) {
                    NavigationLink(destination: WallpaperDetailView(wallpapers: wallpapers, selectedIndex: index)) {
                        ZStack {
                            // Placeholder image
                            Image("placeholder1")
                                .resizable()
                                .scaledToFill()
                                .frame(width: cellWidth, height: cellHeight)
                                .cornerRadius(16)
                                .clipped()
                            
                            // WebImage without indicator
                            WebImage(url: URL(string: wallpaper.src.medium))
                                .resizable()
                                .scaledToFill()
                                .frame(width: cellWidth, height: cellHeight)
                                .cornerRadius(16)
                                .clipped()
                        }
                        .onAppear {
                            // Preload next images when approaching the end
                            if index >= wallpapers.count - 6 {
                                let urls = wallpapers.suffix(6).compactMap { URL(string: $0.src.medium) }
                                SDWebImagePrefetcher.shared.prefetchURLs(urls)
                            }
                            
                            // Trigger load more when approaching the end
                            if index >= wallpapers.count - 4 && hasMorePages && !isLoading {
                                loadMore()
                            }
                        }
                    }
                    
                    // Favorite Button with Bounce Effect
                    FavoriteButton(
                        isFavorite: favoritesManager.isFavorite(wallpaper),
                        action: {
                            favoritesManager.toggleFavorite(wallpaper)
                        }
                    )
                    .padding(8)
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
        .toast(isShowing: $favoritesManager.showToast, message: favoritesManager.toastMessage)
    }
}

// MARK: - Top Gradient View
struct TopGradientView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var animateFavorite = false
    @State private var showingSetting = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Wallpaper")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Favorite Icon - Navigation to Favorites with animation
                NavigationLink(destination: FavouriteWallpaperListView()) {
                    Image("favourite_home")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                        .scaleEffect(animateFavorite ? 1.2 : 1.0)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    // Animate when tapped
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        animateFavorite = true
                    }
                    
                    // Reset animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            animateFavorite = false
                        }
                    }
                })
                .padding(.trailing, 8)
                
                // Settings Icon - Navigate to SettingView
                NavigationLink(destination: SettingView()) {
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
                        .stroke(isSelected ? Color.pageSelected : Color.clear, lineWidth: 1)
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
    let fixedWidth: CGFloat = 120 // Fixed width of 250
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<numberOfPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.pageSelected : Color.pageUnselected)
                            .frame(width: 8, height: 8)
                            .id(index) // Add ID for scroll positioning
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(width: fixedWidth) // Fixed width container
            .frame(maxWidth: .infinity) // Center it horizontally
            .disabled(true) // Disable user interaction - prevents manual scrolling
            .onChange(of: currentPage) { newPage in
                // Calculate the target index to scroll to
                // We want to center the selected dot in the visible area
                let targetIndex = min(max(newPage, 0), numberOfPages - 1)
                
                withAnimation {
                    // Scroll to the selected index
                    proxy.scrollTo(targetIndex, anchor: .center)
                }
            }
        }
    }
}
// MARK: - Wallpaper Banner View
struct WallpaperBannerView: View {
    
    var bannerHeight: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 140 : 110
    }
    
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            // Background Image
            Image("wall_banner")
                .resizable()
                .scaledToFill()
                .frame(width: screenWidth - 30, height: bannerHeight)
                .clipped()
                .cornerRadius(20)
            
            // Text Content
            VStack(alignment: .leading, spacing: 6) {
                
                Text("Live Wallpaper")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Set animated wallpapers effortlessly")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.leading, 20)
        }
        .frame(width: screenWidth - 30, height: bannerHeight)
    }
}
// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
