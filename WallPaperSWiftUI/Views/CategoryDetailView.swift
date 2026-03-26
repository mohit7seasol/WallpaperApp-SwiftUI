//
//  CategoryDetailView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 27/02/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct CategoryDetailView: View {
    let category: StaticCategory
    @StateObject private var viewModel = CategoryWallpaperViewModel()
    @StateObject private var favoritesManager = FavoritesManager.shared
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
    // Get screen width
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
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            Color.appBgColor
                .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(viewModel.wallpapers.enumerated()), id: \.element.id) { index, wallpaper in
                        ZStack(alignment: .bottomTrailing) {
                            NavigationLink(destination: WallpaperDetailView(wallpapers: viewModel.wallpapers, selectedIndex: index)) {
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
                                    if index >= viewModel.wallpapers.count - 6 {
                                        let urls = viewModel.wallpapers.suffix(6).compactMap { URL(string: $0.src.original) }
                                        SDWebImagePrefetcher.shared.prefetchURLs(urls)
                                    }
                                    
                                    // Trigger load more when approaching the end
                                    if index >= viewModel.wallpapers.count - 4 && viewModel.hasMorePages && !viewModel.isLoading {
                                        viewModel.loadMore()
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
                    if viewModel.isLoading && !viewModel.wallpapers.isEmpty {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .navigationTitle(category.title.localized(language))
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.white)
        .onAppear {
            viewModel.fetchWallpapers(for: category.searchKeyword, loadMore: false)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: FavouriteWallpaperListView()) {
                    Image("favourite_home")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
            }
        }
        .onDisappear {
            // Clear prefetcher when leaving view
            SDWebImagePrefetcher.shared.cancelPrefetching()
            // Cancel any ongoing requests
            NetworkManager.cancelAllRequests()
        }
        .toast(isShowing: $favoritesManager.showToast, message: favoritesManager.toastMessage)
    }
}
