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
                // Custom Navigation Bar (similar to CategoryDetailView)
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
                    
                    // Clear all button (optional)
                    if !favoritesManager.favoriteWallpapers.isEmpty {
                        Button(action: {
                            favoritesManager.clearAllFavorites()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    } else {
                        // Empty view for balance
                        Color.clear
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                if favoritesManager.favoriteWallpapers.isEmpty {
                    // Empty State View (with animation)
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                            .scaleEffect(favoritesManager.showToast ? 0.8 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: favoritesManager.showToast)
                        
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
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
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
                                    ZStack(alignment: .bottomTrailing) {
                                        WebImage(url: URL(string: wallpaper.src.medium))
                                            .resizable()
                                            .indicator(.activity)
                                            .transition(.fade(duration: 0.5))
                                            .scaledToFill()
                                            .frame(width: cellWidth, height: cellWidth * 1.5)
                                            .clipped()
                                            .cornerRadius(12)
                                        
                                        // Favorite Button with Bounce Effect
                                        FavoriteButton(
                                            isFavorite: true,
                                            action: {
                                                favoritesManager.toggleFavorite(wallpaper)
                                            }
                                        )
                                        .padding(8)
                                    }
                                    .frame(width: cellWidth)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .toast(isShowing: $favoritesManager.showToast, message: favoritesManager.toastMessage)
    }
}
