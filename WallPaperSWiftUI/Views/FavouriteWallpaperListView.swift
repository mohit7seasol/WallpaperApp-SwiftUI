//
//  FavouriteWallpaperListView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 02/03/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct FavouriteWallpaperListView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @State private var showToast = false
    @State private var toastMessage = ""
    @Environment(\.dismiss) private var dismiss
    
    let screenWidth = UIScreen.main.bounds.width
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var cellWidth: CGFloat {
        return (screenWidth - 48) / 3 // screenWidth/3 with padding
    }
    
    var body: some View {
        ZStack {
            Color.backgroundBlack
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Navigation Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Favorites")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Empty view for balance
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                if favoritesManager.favoriteWallpapers.isEmpty {
                    // Empty State View
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                        
                        Text("No Favorites Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Text("Your favorite wallpapers will appear here")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: { dismiss() }) {
                            Text("Browse Wallpapers")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(25)
                        }
                        .padding(.top, 20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Favorites Grid
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Array(favoritesManager.favoriteWallpapers.enumerated()), id: \.element.id) { index, wallpaper in
                                NavigationLink(destination: WallpaperDetailView(wallpapers: favoritesManager.favoriteWallpapers, selectedIndex: index)) {
                                    FavoriteWallpaperCell(
                                        wallpaper: wallpaper,
                                        cellWidth: cellWidth,
                                        onFavoriteToggle: {
                                            favoritesManager.toggleFavorite(wallpaper)
                                            toastMessage = favoritesManager.isFavorite(wallpaper) ? "Added to favorites" : "Removed from favorites"
                                            showToast = true
                                            
                                            // Hide toast after 2 seconds
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                showToast = false
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            
            // Toast Message
            if showToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(20)
                        .padding(.bottom, 30)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut, value: showToast)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Favorite Wallpaper Cell
struct FavoriteWallpaperCell: View {
    let wallpaper: PexelWallpaperData
    let cellWidth: CGFloat
    let onFavoriteToggle: () -> Void
    
    @State private var isFavorite: Bool = true
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WebImage(url: URL(string: wallpaper.src.medium))
                .resizable()
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFill()
                .frame(width: cellWidth, height: cellWidth * 1.5) // Height based on image aspect
                .clipped()
                .cornerRadius(12)
            
            // Favorite Button
            Button(action: {
                isFavorite.toggle()
                onFavoriteToggle()
            }) {
                Image(isFavorite ? "favourite" : "unfavourite")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.white)
                    .background(Color.white.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding(8)
        }
        .frame(width: cellWidth)
        .onAppear {
            isFavorite = FavoritesManager.shared.isFavorite(wallpaper)
        }
    }
}
