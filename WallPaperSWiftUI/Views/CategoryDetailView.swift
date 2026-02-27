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
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            Color.backgroundBlack
                .ignoresSafeArea()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(viewModel.wallpapers.enumerated()), id: \.element.id) { index, wallpaper in
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
                                        if index >= viewModel.wallpapers.count - 6 {
                                            SDWebImagePrefetcher.shared.prefetchURLs(
                                                viewModel.wallpapers.suffix(6).compactMap { URL(string: $0.path ?? "") }
                                            )
                                        }
                                        
                                        // Trigger load more when approaching the end
                                        if index >= viewModel.wallpapers.count - 4 && viewModel.hasMorePages && !viewModel.isLoading {
                                            viewModel.loadMore()
                                        }
                                    }
                            }
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
        .navigationTitle(category.title)
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.white)
        .onAppear {
            viewModel.fetchWallpapers(for: category.searchKeyword, loadMore: false)
        }
        .onDisappear {
            // Clear prefetcher when leaving view
            SDWebImagePrefetcher.shared.cancelPrefetching()
            // Cancel any ongoing requests
            NetworkManager.cancelAllRequests()
        }
    }
}

