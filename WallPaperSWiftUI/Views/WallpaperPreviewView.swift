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
            GeometryReader { geo in
                WebImage(url: URL(string: imageURL))
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
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
    @ViewBuilder
    var dockBackground: some View {
        if AppVersion.isIOS26 {
            // ✅ Native glass (iOS 26+)
            Color.clear
                .background(.ultraThinMaterial)
        } else {
            // ✅ Custom glass (fallback)
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.15))
                
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
            }
        }
    }
    
    var homePreview: some View {
        VStack {
            Spacer() // Pushes content to bottom
            
            // MARK: Dock
            HStack(spacing: 25) {
                dockIcon("Call_ic")
                dockIcon("Safari_ic")
                dockIcon("Message_ic")
                dockIcon("Music_ic")
            }
            .padding(.horizontal, 20)
            .frame(height: 88)
            .frame(maxWidth: .infinity)
            .background(dockBackground) // ✅ NEW
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
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
// MARK: - LOCK PREVIEW (FIXED LAYOUT)
////////////////////////////////////////////////////////////

private extension WallpaperPreviewView {
    
    var lockPreview: some View {
        VStack(spacing: 10) {
            // Top spacing of 40 (using padding top on VStack)
            Text(currentDate)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 50) // Top padding 40
            
            Text(currentTime)
                .font(.system(size: 72, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Capsule()
                .fill(Color.white.opacity(0.7))
                .frame(width: 140, height: 5)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 20) // Left and right padding 20
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
