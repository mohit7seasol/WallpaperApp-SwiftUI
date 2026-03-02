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
                Color.backgroundBlack
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
                    .padding(.top, -32)
                    
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
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(Array(wallpapers.enumerated()), id: \.element.id) { index, wallpaper in
                NavigationLink(destination: WallpaperDetailView(wallpapers: wallpapers, selectedIndex: index)) {
                    WebImage(url: URL(string: wallpaper.src.medium))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFill()
                        .frame(width: cellWidth, height: cellHeight)
                        .cornerRadius(16)
                        .clipped()
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
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                // Favorite Icon
                Button(action: {}) {
                    Image("favourite_home")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
                .padding(.trailing, 8)
                
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
                /* .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .offset(x: 150, y: -30)
                ) */
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
    let fixedWidth: CGFloat = 200 // Fixed width of 250
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<numberOfPages, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.pageSelected : Color.pageUnselected)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(width: fixedWidth) // Fixed width container
        .frame(maxWidth: .infinity) // Center it horizontally
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
