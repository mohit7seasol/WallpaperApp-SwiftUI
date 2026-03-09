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
    @AppStorage(SessionKeys.language) var language = LocalizationService.shared.language
    
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
            Color.appBgColor
                .ignoresSafeArea()
            
            if favoritesManager.favoriteWallpapers.isEmpty {
                // Empty State View
                VStack(spacing: 20) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 70))
                        .foregroundColor(.gray)
                    
                    Text("No Favorites Yet".localized(language))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Your favorite wallpapers will appear here".localized(language))
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Button(action: { dismiss() }) {
                        Text("Browse Wallpapers".localized(language))
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.gradientOne, Color.gradientTwo.opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
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
                                    // Placeholder image
                                    Image("placeholder2")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: cellWidth, height: cellWidth * 1.5)
                                        .clipped()
                                        .cornerRadius(12)
                                    
                                    // WebImage without indicator
                                    WebImage(url: URL(string: wallpaper.src.medium))
                                        .resizable()
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
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Favorites".localized(language))
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.white)
        .toolbar {
            // This empty toolbar ensures we don't get any additional navigation items
            ToolbarItem(placement: .navigationBarLeading) {
                EmptyView()
            }
        }
    }
}
