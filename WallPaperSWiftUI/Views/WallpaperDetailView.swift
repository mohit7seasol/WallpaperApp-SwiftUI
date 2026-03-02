//
//  WallpaperDetailView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 02/03/26.
//

import SwiftUI
import SDWebImageSwiftUI
import ACarousel

struct WallpaperDetailView: View {
    
    let wallpapers: [PexelWallpaperData]
    
    @State private var selectedIndex: Int
    @State private var isFavorite: Bool = false
    @State private var showDownloadOptions = false
    @State private var selectedWallpaperForDownload: PexelWallpaperData?
    @StateObject private var favoritesManager = FavoritesManager.shared
    
    @Environment(\.dismiss) private var dismiss
    
    init(wallpapers: [PexelWallpaperData], selectedIndex: Int) {
        self.wallpapers = wallpapers
        self._selectedIndex = State(initialValue: selectedIndex)
    }
    
    var body: some View {
        ZStack {
            
            // MARK: - Clean Dark Background
            Constant.previewBlueGradient
                .ignoresSafeArea()
            VStack(spacing: 0) {
                
                topBar
                    .padding(.top, 50)
                
                Spacer(minLength: 20)
                
                carouselView
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                
                Spacer(minLength: 20)
                
                bottomBar
                    .padding(.bottom, 0)
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .onAppear {
            checkFavoriteStatus()
        }
        .actionSheet(isPresented: $showDownloadOptions) {
            ActionSheet(
                title: Text("Select Image Quality"),
                message: Text("Choose the quality to download"),
                buttons: getDownloadButtons()
            )
        }
    }
    
    // Get download buttons based on available image qualities
    private func getDownloadButtons() -> [ActionSheet.Button] {
        guard let wallpaper = selectedWallpaperForDownload ?? wallpapers[safe: selectedIndex] else {
            return [.cancel()]
        }
        
        var buttons: [ActionSheet.Button] = []
        
        // Add all available qualities
        buttons.append(.default(Text("Original")) {
            downloadImage(from: wallpaper.src.original, quality: "Original")
        })
        
        buttons.append(.default(Text("Large 2X")) {
            downloadImage(from: wallpaper.src.large2x, quality: "Large 2X")
        })
        
        buttons.append(.default(Text("Large")) {
            downloadImage(from: wallpaper.src.large, quality: "Large")
        })
        
        buttons.append(.default(Text("Medium")) {
            downloadImage(from: wallpaper.src.medium, quality: "Medium")
        })
        
        buttons.append(.default(Text("Portrait")) {
            downloadImage(from: wallpaper.src.portrait, quality: "Portrait")
        })
        
        buttons.append(.default(Text("Landscape")) {
            downloadImage(from: wallpaper.src.landscape, quality: "Landscape")
        })
        
        buttons.append(.default(Text("Small")) {
            downloadImage(from: wallpaper.src.small, quality: "Small")
        })
        
        buttons.append(.default(Text("Tiny")) {
            downloadImage(from: wallpaper.src.tiny, quality: "Tiny")
        })
        
        buttons.append(.cancel())
        
        return buttons
    }
    
    // Download image function
    private func downloadImage(from urlString: String, quality: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        // Show loading indicator
        let loadingVC = UIAlertController(title: "Downloading...", message: "Please wait", preferredStyle: .alert)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(loadingVC, animated: true)
        }
        
        // Download image
        URLSession.shared.downloadTask(with: url) { localURL, response, error in
            DispatchQueue.main.async {
                // Dismiss loading
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.dismiss(animated: true)
                }
                
                if let error = error {
                    print("Download error: \(error)")
                    showDownloadCompleteAlert(success: false, message: error.localizedDescription)
                    return
                }
                
                guard let localURL = localURL else {
                    showDownloadCompleteAlert(success: false, message: "Failed to download image")
                    return
                }
                
                // Save to photo library
                if let imageData = try? Data(contentsOf: localURL),
                   let image = UIImage(data: imageData) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    showDownloadCompleteAlert(success: true, message: "Image saved to photos (\(quality) quality)")
                } else {
                    showDownloadCompleteAlert(success: false, message: "Failed to save image")
                }
            }
        }.resume()
    }
    
    // Show download completion alert
    private func showDownloadCompleteAlert(success: Bool, message: String) {
        let alert = UIAlertController(
            title: success ? "Success" : "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - TOP BAR
////////////////////////////////////////////////////////////

private extension WallpaperDetailView {
    
    var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

////////////////////////////////////////////////////////////
// MARK: - CAROUSEL
////////////////////////////////////////////////////////////

private extension WallpaperDetailView {
    
    var carouselView: some View {
        
        GeometryReader { geo in
            
            ACarousel(
                wallpapers,
                id: \.id,
                index: $selectedIndex,
                spacing: 10,
                headspace: 35,
                sidesScaling: 0.85,
                isWrap: true,
                autoScroll: .inactive
            ) { wallpaper in
                
                WallpaperCardView(
                    wallpaper: wallpaper,
                    width: geo.size.width * 0.8,
                    height: geo.size.height * 0.85
                )
                .scaleEffect(wallpaper.id == wallpapers[selectedIndex].id ? 1.0 : 0.95)
                .shadow(color: wallpaper.id == wallpapers[selectedIndex].id ?
                        Color.white.opacity(0.3) : Color.clear,
                        radius: 15, x: 0, y: 0)
                .zIndex(wallpaper.id == wallpapers[selectedIndex].id ? 2 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedIndex)
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.75)
    }
}

////////////////////////////////////////////////////////////
// MARK: - WALLPAPER CARD VIEW
////////////////////////////////////////////////////////////

struct WallpaperCardView: View {
    
    let wallpaper: PexelWallpaperData
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        
        ZStack {
            
            // Black background inside card
            Color.black
            
            WebImage(url: URL(string: wallpaper.src.large))
                .resizable()
                .indicator(.activity)
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
        }
        .frame(width: width, height: height)
        .cornerRadius(32)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
        )
        .shadow(color: .black.opacity(0.5),
                radius: 20,
                x: 0,
                y: 10)
    }
}

////////////////////////////////////////////////////////////
// MARK: - BOTTOM BAR
////////////////////////////////////////////////////////////

private extension WallpaperDetailView {
    
    var bottomBar: some View {
        HStack(spacing: 25) {
            Button {
                shareWallpaper()
            } label: {
                Image("share_ic")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
            }
            
            Button {
                // Show download options
                selectedWallpaperForDownload = wallpapers[safe: selectedIndex]
                showDownloadOptions = true
            } label: {
                HStack(spacing: 8) {
                    Image("down_arrow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("Download")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(height: 58)
                .padding(.horizontal, 50)
                .background(Color.white.opacity(0.15))
                .cornerRadius(10)
            }
            
            Button {
                toggleFavorite()
            } label: {
                Image(isFavorite ? "favourite_detail" : "unfavourite_detail")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 42, height: 42)
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
            }
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - ACTIONS
////////////////////////////////////////////////////////////

private extension WallpaperDetailView {
    
    func checkFavoriteStatus() {
        guard let wallpaper = wallpapers[safe: selectedIndex] else { return }
        isFavorite = favoritesManager.isFavorite(wallpaper)
    }
    
    func toggleFavorite() {
        guard let wallpaper = wallpapers[safe: selectedIndex] else { return }
        favoritesManager.toggleFavorite(wallpaper)
        isFavorite.toggle()
    }
    
    func shareWallpaper() {
        guard let wallpaper = wallpapers[safe: selectedIndex],
              let url = URL(string: wallpaper.src.large) else { return }
        
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(vc, animated: true)
        }
    }
}

// MARK: - Safe Array Extension
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
