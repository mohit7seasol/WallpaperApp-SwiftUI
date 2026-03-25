//
//  WallpaperPreviewView.swift
//  WallPaperSWiftUI
//
//  Created by DREAMWORLD on 25/03/26.
//

import SwiftUI
import SDWebImageSwiftUI

// ✅ SINGLE ENUM (FIXED)
enum PreviewMode {
    case wallpaper
    case home
    case lock
}

struct WallpaperPreviewView: View {
    
    let imageURL: String
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var previewMode: PreviewMode = .wallpaper // ✅ start with wallpaper
    @State private var showNavBar: Bool = true
    @State private var showDownloadOptions = false
    
    var body: some View {
        ZStack {
            
            // MARK: Wallpaper
            WebImage(url: URL(string: imageURL))
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            overlayView
        }
        
        // ✅ NAV BAR CONTROL
        .navigationBarBackButtonHidden(!showNavBar)
        .toolbar(showNavBar ? .visible : .hidden, for: .navigationBar)
        .toolbar {
            if showNavBar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showDownloadOptions = true
                    } label: {
                        Image(systemName: "arrow.down.circle")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        
        // ✅ TAP FLOW (wallpaper → home → lock → wallpaper)
        .onTapGesture {
            withAnimation(.easeInOut) {
                switch previewMode {
                case .wallpaper:
                    previewMode = .home
                    showNavBar = false
                    
                case .home:
                    previewMode = .lock
                    
                case .lock:
                    previewMode = .wallpaper
                    showNavBar = true
                }
            }
        }
        
        .actionSheet(isPresented: $showDownloadOptions) {
            ActionSheet(
                title: Text("Download"),
                buttons: [
                    .default(Text("Download")) {
                        downloadImage(from: imageURL)
                    },
                    .cancel()
                ]
            )
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - OVERLAY SWITCH
////////////////////////////////////////////////////////////

private extension WallpaperPreviewView {
    
    @ViewBuilder
    var overlayView: some View {
        switch previewMode {
        case .wallpaper:
            EmptyView()
        case .home:
            homePreview
        case .lock:
            lockPreview
        }
    }
}

////////////////////////////////////////////////////////////
// MARK: - HOME PREVIEW (FIXED LAYOUT)
////////////////////////////////////////////////////////////

private extension WallpaperPreviewView {
    
    var homePreview: some View {
        VStack(spacing: 0) {
            
            // ✅ Top spacing (safe + visual balance)
            Color.clear
                .frame(height: getSafeAreaTop() + 20)
            
            // MARK: Widgets
            HStack(spacing: 16) {
                
                Image("weather_ic")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(22)
                
                Image("photos_ic")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(22)
            }
            .padding(.horizontal, 20)
            
            // MARK: App Grid
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4),
                spacing: 22
            ) {
                appIcon("FaceTime_ic", "FaceTime")
                appIcon("Calendar_ic", "Calendar")
                appIcon("Gallery_ic", "Photos")
                appIcon("Camera_ic", "Camera")
                appIcon("Mail_ic", "Mail")
                appIcon("Note_ic", "Notes")
                appIcon("Reminders_ic", "Reminders")
                appIcon("Clock_ic", "Clock")
            }
            .padding(.top, 25)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // MARK: Dock
            HStack(spacing: 25) {
                dockIcon("Call_ic")
                dockIcon("Safari_ic")
                dockIcon("Message_ic")
                dockIcon("Music_ic")
            }
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                Image("Glass_bg")
                    .resizable()
                    .scaledToFill()
            )
            .cornerRadius(30)
            .padding(.horizontal, 20)
            .padding(.bottom, getSafeAreaBottom() + 10)
        }
        .ignoresSafeArea()
    }
    
    func appIcon(_ image: String, _ title: String) -> some View {
        VStack(spacing: 6) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white)
        }
    }
    
    func dockIcon(_ image: String) -> some View {
        Image(image)
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
    }
    
    func getSafeAreaTop() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.top }
            .first ?? 0
    }
    
    func getSafeAreaBottom() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom }
            .first ?? 0
    }
}

////////////////////////////////////////////////////////////
// MARK: - LOCK PREVIEW
////////////////////////////////////////////////////////////

private extension WallpaperPreviewView {
    
    var lockPreview: some View {
        VStack(spacing: 10) {
            
            Spacer()
            
            Text(currentDate)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
            
            Text(currentTime)
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Capsule()
                .fill(Color.white.opacity(0.7))
                .frame(width: 140, height: 5)
                .padding(.bottom, 20)
        }
        .ignoresSafeArea()
    }
    
    var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
    
    var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: Date())
    }
}

////////////////////////////////////////////////////////////
// MARK: - DOWNLOAD
////////////////////////////////////////////////////////////

private extension WallpaperPreviewView {
    
    func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let loading = UIAlertController(title: "Downloading...", message: nil, preferredStyle: .alert)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(loading, animated: true)
        }
        
        URLSession.shared.downloadTask(with: url) { localURL, _, _ in
            DispatchQueue.main.async {
                
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.windows.first?.rootViewController {
                    root.dismiss(animated: true)
                }
                
                guard let localURL = localURL,
                      let data = try? Data(contentsOf: localURL),
                      let image = UIImage(data: data) else { return }
                
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }.resume()
    }
}
